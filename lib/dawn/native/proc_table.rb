# frozen_string_literal: true

module Dawn
  module Native
    class DawnProcTable < FFI::Struct
      layout :opaque, :pointer
    end

    class << self
      def get_procs
        return nil unless respond_to?(:dawn_native_GetProcs)

        ptr = dawn_native_GetProcs
        return nil if ptr.nil? || ptr.null?

        ptr
      end

      def set_procs!(ptr = get_procs)
        return false unless ptr && respond_to?(:dawnProcSetProcs)

        dawnProcSetProcs(ptr)
        true
      end
    end
  end
end
