# frozen_string_literal: true

require "rbconfig"
require_relative "errors"

module Dawn
  module Loader
    LIBRARY_NAMES = {
      "linux" => ["libdawn.so", "libwebgpu_dawn.so"],
      "darwin" => ["libdawn.dylib", "libwebgpu_dawn.dylib"],
      "mingw" => ["dawn.dll", "webgpu_dawn.dll"],
      "mswin" => ["dawn.dll", "webgpu_dawn.dll"]
    }.freeze

    class << self
      def activate!
        ENV["WGPU_LIB_PATH"] = resolve_library_path
      end

      def library_path
        path = ENV["DAWN_LIBRARY_PATH"] || ENV["WGPU_LIB_PATH"]
        return path if path && File.exist?(path)

        resolve_library_path
      end

      def resolve_library_path
        explicit = ENV["DAWN_LIBRARY_PATH"]
        if explicit
          return explicit if File.file?(explicit)
          raise Dawn::LoadError, "DAWN_LIBRARY_PATH points to non-existent file: #{explicit}"
        end

        candidates.each do |path|
          return path if File.file?(path)
        end

        raise Dawn::LoadError, <<~MSG
          Dawn library not found.
          Searched:
            #{candidates.join("\n  ")}

          Set DAWN_LIBRARY_PATH to a Dawn shared library path.
        MSG
      end

      def cache_dir
        File.join(Dir.home, ".cache", "dawn-ruby", Dawn::VERSION)
      end

      private

      def candidates
        names = library_names
        search_roots.flat_map { |root| names.map { |name| File.join(root, name) } }
      end

      def search_roots
        [
          ENV["DAWN_LIBRARY_DIR"],
          File.join(cache_dir, "lib"),
          "/usr/local/lib",
          "/usr/lib",
          File.join(Dir.pwd, "ext", "dawn", "lib")
        ].compact.uniq
      end

      def library_names
        host = RbConfig::CONFIG["host_os"]
        key = LIBRARY_NAMES.keys.find { |candidate| host.include?(candidate) }
        raise Dawn::LoadError, "Unsupported OS for Dawn loader: #{host}" unless key

        LIBRARY_NAMES.fetch(key)
      end
    end
  end
end
