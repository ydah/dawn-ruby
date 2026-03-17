# frozen_string_literal: true

require "rbconfig"
require_relative "errors"
require_relative "upstream"

module Dawn
  module Loader
    class << self
      def activate!
        ENV["WGPU_LIB_PATH"] = library_path
      end

      def library_path
        path = ENV["DAWN_LIBRARY_PATH"] || ENV["WGPU_LIB_PATH"]
        return path if path && File.file?(path)

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
        Dawn::Upstream.cache_dir
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
          bundled_library_dir
        ].compact.uniq
      end

      def library_names
        Dawn::Upstream.library_names(host_os: RbConfig::CONFIG["host_os"])
      end

      def bundled_library_dir
        File.expand_path("../../ext/dawn/lib", __dir__)
      end
    end
  end
end
