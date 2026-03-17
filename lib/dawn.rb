# frozen_string_literal: true

require_relative "dawn/version"
require_relative "dawn/errors"
require_relative "dawn/loader"
require_relative "dawn/native/optional_symbols"

Dawn::Loader.activate!
Dawn::Native.patch_ffi_attach_function!

require "wgpu"

require_relative "dawn/compatibility"
require_relative "dawn/native/enums_ext"
require_relative "dawn/native/structs_ext"
require_relative "dawn/native/functions_ext"
require_relative "dawn/native/proc_table"
Dawn::Native.set_procs!
require_relative "dawn/toggles"
require_relative "dawn/backend"
require_relative "dawn/instance"
require_relative "dawn/adapter"

Dawn::Compatibility.patch!
