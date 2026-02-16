# frozen_string_literal: true

module Dawn
  class Instance
    attr_reader :wgpu_instance

    def initialize(toggles: nil)
      @wgpu_instance = toggles ? create_with_toggles(toggles) : WGPU::Instance.new
    end

    def request_adapter(**options)
      adapter = @wgpu_instance.request_adapter(**options)
      Dawn::Adapter.new(adapter)
    end

    def enumerate_adapters(backends: nil)
      @wgpu_instance.enumerate_adapters(backends: backends).map { |adapter| Dawn::Adapter.new(adapter) }
    end

    def process_events
      @wgpu_instance.process_events
    end

    def release
      @wgpu_instance.release
    end

    def method_missing(name, *args, **kwargs, &block)
      if @wgpu_instance.respond_to?(name)
        return @wgpu_instance.public_send(name, *args, **kwargs, &block)
      end

      super
    end

    def respond_to_missing?(name, include_private = false)
      @wgpu_instance.respond_to?(name, include_private) || super
    end

    private

    def create_with_toggles(toggles)
      desc = WGPU::Native::InstanceDescriptor.new
      desc[:features][:next_in_chain] = nil
      desc[:features][:timed_wait_any_enable] = 0
      desc[:features][:timed_wait_any_max_count] = 0

      toggles_desc = toggles.to_descriptor
      desc[:next_in_chain] = toggles_desc.to_ptr

      handle = WGPU::Native.wgpuCreateInstance(desc)
      raise Dawn::Error, "Failed to create Dawn instance" if handle.null?

      WGPU::Instance.from_handle(handle)
    end
  end
end
