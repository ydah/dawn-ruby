# frozen_string_literal: true

require "fileutils"
require "net/http"
require "uri"

DAWN_VERSION = ENV.fetch("DAWN_VERSION", "v0.0.0")
CACHE_DIR = File.join(Dir.home, ".cache", "dawn-ruby", DAWN_VERSION)
LIB_DIR = File.join(CACHE_DIR, "lib")

PLATFORM_MAP = {
  /x86_64-linux/ => ["libdawn.so", "libwebgpu_dawn.so"],
  /aarch64-linux/ => ["libdawn.so", "libwebgpu_dawn.so"],
  /arm64-darwin/ => ["libdawn.dylib", "libwebgpu_dawn.dylib"],
  /x86_64-darwin/ => ["libdawn.dylib", "libwebgpu_dawn.dylib"],
  /mingw|mswin/ => ["dawn.dll", "webgpu_dawn.dll"]
}.freeze

def detect_library_names
  PLATFORM_MAP.each do |pattern, names|
    return names if RUBY_PLATFORM =~ pattern
  end

  abort "Unsupported platform for Dawn: #{RUBY_PLATFORM}"
end

def already_available?(names)
  explicit = ENV["DAWN_LIBRARY_PATH"]
  return true if explicit && File.file?(explicit)

  names.any? { |name| File.file?(File.join(LIB_DIR, name)) }
end

def download_if_requested
  return unless ENV["DAWN_PREBUILT_URL"]

  url = ENV["DAWN_PREBUILT_URL"]
  archive = File.join(CACHE_DIR, File.basename(URI.parse(url).path))

  FileUtils.mkdir_p(CACHE_DIR)
  FileUtils.mkdir_p(LIB_DIR)

  http = Net::HTTP.new(URI(url).host, URI(url).port)
  http.use_ssl = true if URI(url).scheme == "https"

  request = Net::HTTP::Get.new(URI(url))
  response = http.request(request)
  abort "Failed to download Dawn archive: #{url}" unless response.is_a?(Net::HTTPSuccess)

  File.binwrite(archive, response.body)

  system("tar", "-xf", archive, "-C", CACHE_DIR)
end

def write_makefile
  File.write("Makefile", <<~MAKEFILE)
    .PHONY: install clean

    install:
    \t@echo "dawn-webgpu extension ready"

    clean:
    \t@echo "nothing to clean"
  MAKEFILE
end

names = detect_library_names
download_if_requested

unless already_available?(names)
  warn <<~MSG
    Dawn shared library was not found.
    Provide one of:
      1) Set DAWN_LIBRARY_PATH to an existing Dawn shared library.
      2) Set DAWN_PREBUILT_URL to a tar archive URL containing Dawn libraries.
      3) Place a library at #{File.join(LIB_DIR, names.first)}.
  MSG
end

write_makefile
puts "Done"
