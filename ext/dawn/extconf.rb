# frozen_string_literal: true

require "digest"
require "fileutils"
require "net/http"
require "uri"
require_relative "../../lib/dawn/upstream"

def cache_dir
  Dawn::Upstream.cache_dir
end

def library_dir
  Dawn::Upstream.library_dir
end

def already_available?(names)
  explicit = ENV["DAWN_LIBRARY_PATH"] || ENV["WGPU_LIB_PATH"]
  return true if explicit && File.file?(explicit)

  names.any? { |name| File.file?(File.join(library_dir, name)) }
end

def download_requested?
  ENV["DAWN_DOWNLOAD_PREBUILT"] == "1" || ENV["DAWN_PREBUILT_URL"]
end

def resolve_download_url
  Dawn::Upstream.prebuilt_url
rescue Dawn::LoadError => e
  warn e.message
  nil
end

def download_if_requested
  return unless download_requested?

  url = resolve_download_url
  return unless url

  uri = URI.parse(url)
  basename = File.basename(uri.path)
  basename = Dawn::Upstream.prebuilt_archive_name if basename.nil? || basename.empty? || basename == "/"
  archive = File.join(cache_dir, basename)

  FileUtils.mkdir_p(cache_dir)

  download_archive(url, archive)
  verify_archive!(archive)
  extract_archive(archive, cache_dir)
end

def download_archive(url, destination, limit: 5)
  raise "Too many redirects while downloading #{url}" if limit.zero?

  uri = URI.parse(url)
  request = Net::HTTP::Get.new(uri)

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request) do |response|
      case response
      when Net::HTTPSuccess
        File.open(destination, "wb") do |file|
          response.read_body { |chunk| file.write(chunk) }
        end
      when Net::HTTPRedirection
        redirected = URI.join(url, response["location"]).to_s
        download_archive(redirected, destination, limit: limit - 1)
      else
        raise "Failed to download Dawn archive: #{url} (#{response.code} #{response.message})"
      end
    end
  end
end

def verify_archive!(archive)
  expected = ENV["DAWN_PREBUILT_SHA256"]
  return if expected.nil? || expected.empty?

  actual = Digest::SHA256.file(archive).hexdigest
  return if actual == expected

  raise "Downloaded Dawn archive checksum mismatch for #{archive}"
end

def extract_archive(archive, destination)
  success =
    if archive.end_with?(".zip")
      system("unzip", "-oq", archive, "-d", destination)
    else
      system("tar", "-xf", archive, "-C", destination)
    end

  raise "Failed to extract Dawn archive: #{archive}" unless success
end

def write_makefile
  File.write(File.join(__dir__, "Makefile"), <<~MAKEFILE)
    .PHONY: install clean

    install:
    \t@echo "dawn-webgpu extension ready"

    clean:
    \t@echo "nothing to clean"
  MAKEFILE
end

names = Dawn::Upstream.library_names
download_if_requested unless already_available?(names)

unless already_available?(names)
  warn <<~MSG
    Dawn shared library was not found.
    Provide one of:
      1) Set DAWN_LIBRARY_PATH to an existing Dawn shared library.
      2) Run `DAWN_DOWNLOAD_PREBUILT=1 bundle exec ruby ext/dawn/extconf.rb`.
      3) Set DAWN_PREBUILT_URL to a Dawn prebuilt archive URL.
      4) Place a library at #{File.join(library_dir, names.first)}.
  MSG
end

write_makefile
puts "Done"
