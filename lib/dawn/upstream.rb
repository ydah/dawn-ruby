# frozen_string_literal: true

require "rbconfig"
require_relative "errors"

module Dawn
  module Upstream
    DEFAULT_VERSION = "7187"
    DEFAULT_MIRROR = "https://github.com/eliemichel/dawn-prebuilt"
    DEFAULT_BUILD_TYPE = "Release"

    class << self
      def version
        env_or_default("DAWN_VERSION", DEFAULT_VERSION)
      end

      def mirror
        env_or_default("DAWN_PREBUILT_MIRROR", DEFAULT_MIRROR)
      end

      def build_type
        raw = env_or_default("DAWN_BUILD_TYPE", DEFAULT_BUILD_TYPE)
        raw[0].upcase + raw[1..].downcase
      end

      def cache_dir(version: self.version)
        File.join(Dir.home, ".cache", "dawn-ruby", version)
      end

      def library_dir(version: self.version)
        File.join(cache_dir(version: version), "lib")
      end

      def library_names(host_os: RbConfig::CONFIG["host_os"])
        case normalized_os(host_os)
        when "linux"
          ["libdawn.so", "libwebgpu_dawn.so"]
        when "darwin"
          ["libdawn.dylib", "libwebgpu_dawn.dylib"]
        when "windows"
          ["dawn.dll", "webgpu_dawn.dll"]
        else
          raise Dawn::LoadError, "Unsupported OS for Dawn loader: #{host_os}"
        end
      end

      def prebuilt_supported?(host_os: RbConfig::CONFIG["host_os"], host_cpu: RbConfig::CONFIG["host_cpu"])
        prebuilt_target(host_os: host_os, host_cpu: host_cpu)
        true
      rescue Dawn::LoadError
        false
      end

      def prebuilt_archive_name(
        host_os: RbConfig::CONFIG["host_os"],
        host_cpu: RbConfig::CONFIG["host_cpu"],
        version: self.version,
        build_type: self.build_type
      )
        "Dawn-#{version}-#{prebuilt_target(host_os: host_os, host_cpu: host_cpu)}-#{build_type}.zip"
      end

      def prebuilt_url(
        host_os: RbConfig::CONFIG["host_os"],
        host_cpu: RbConfig::CONFIG["host_cpu"],
        version: self.version,
        mirror: self.mirror,
        build_type: self.build_type
      )
        explicit = ENV["DAWN_PREBUILT_URL"]
        return explicit unless explicit.nil? || explicit.empty?

        archive_name = prebuilt_archive_name(
          host_os: host_os,
          host_cpu: host_cpu,
          version: version,
          build_type: build_type
        )
        "#{mirror}/releases/download/#{release_tag(version: version)}/#{archive_name}"
      end

      def release_tag(version: self.version)
        "chromium/#{version}"
      end

      private

      def env_or_default(name, fallback)
        value = ENV[name]
        return fallback if value.nil? || value.empty?

        value
      end

      def normalized_os(host_os)
        host = host_os.to_s.downcase
        return "darwin" if host.include?("darwin")
        return "linux" if host.include?("linux")
        return "windows" if host.include?("mingw") || host.include?("mswin")

        nil
      end

      def normalized_cpu(host_cpu)
        cpu = host_cpu.to_s.downcase
        return "aarch64" if %w[arm64 aarch64].include?(cpu)
        return "x64" if %w[x86_64 amd64].include?(cpu)

        cpu
      end

      def prebuilt_target(host_os:, host_cpu:)
        case [normalized_os(host_os), normalized_cpu(host_cpu)]
        when ["linux", "x64"]
          "linux-x64"
        when ["darwin", "aarch64"]
          "macos-aarch64"
        when ["darwin", "x64"]
          "macos-x64"
        when ["windows", "x64"]
          "windows-x64"
        else
          raise Dawn::LoadError, "No official Dawn prebuilt archive for #{host_os}/#{host_cpu}"
        end
      end
    end
  end
end
