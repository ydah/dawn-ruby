# frozen_string_literal: true

module Dawn
  module Native
    class DawnTogglesDescriptor < FFI::Struct
      layout :chain, WGPU::Native::ChainedStruct,
             :enabled_toggle_count, :size_t,
             :enabled_toggles, :pointer,
             :disabled_toggle_count, :size_t,
             :disabled_toggles, :pointer
    end

    class DawnTextureInternalUsageDescriptor < FFI::Struct
      layout :chain, WGPU::Native::ChainedStruct,
             :internal_usage, :uint64
    end

    class DawnBufferHostMappedPointer < FFI::Struct
      layout :chain, WGPU::Native::ChainedStruct,
             :pointer, :pointer,
             :dispose_callback, :pointer,
             :userdata, :pointer
    end

    class DawnShaderModuleSPIRVOptionsDescriptor < FFI::Struct
      layout :chain, WGPU::Native::ChainedStruct,
             :allow_non_uniform_derivatives, :uint32
    end
  end
end
