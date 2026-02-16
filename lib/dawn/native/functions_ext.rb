# frozen_string_literal: true

require "ffi"

module Dawn
  module Native
    extend FFI::Library

    ffi_lib Dawn::Loader.library_path

    begin
      attach_function :dawnProcSetProcs, [:pointer], :void
    rescue FFI::NotFoundError
    end

    begin
      attach_function :dawn_native_GetProcs, [], :pointer
    rescue FFI::NotFoundError
    end
  end
end
