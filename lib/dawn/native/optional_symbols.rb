# frozen_string_literal: true

require "ffi"

module Dawn
  module Native
    module OptionalSymbols
      OPTIONAL_SYMBOLS = %i[
        wgpuInstanceEnumerateAdapters
        wgpuDevicePoll
      ].freeze

      def attach_function(name, *args)
        super
      rescue FFI::NotFoundError
        raise unless OPTIONAL_SYMBOLS.include?(name.to_sym)

        define_singleton_method(name) do |*|
          raise FFI::NotFoundError, "Function '#{name}' not available in current backend"
        end
      end
    end

    class << self
      def patch_ffi_attach_function!
        return if @optional_symbols_patched

        FFI::Library.prepend(OptionalSymbols)
        @optional_symbols_patched = true
      end
    end
  end
end
