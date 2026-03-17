# frozen_string_literal: true

module Dawn
  class Adapter
    attr_reader :wgpu_adapter

    def initialize(wgpu_adapter)
      @wgpu_adapter = wgpu_adapter
    end

    def info
      @wgpu_adapter.info
    end

    def backend
      info[:backend_type]
    end

    def features
      @wgpu_adapter.features
    end

    def has_feature?(feature)
      @wgpu_adapter.has_feature?(feature)
    end

    def request_device(**options)
      @wgpu_adapter.request_device(**options)
    end

    def method_missing(name, *args, **kwargs, &block)
      if @wgpu_adapter.respond_to?(name)
        return @wgpu_adapter.public_send(name, *args, **kwargs, &block)
      end

      super
    end

    def respond_to_missing?(name, include_private = false)
      @wgpu_adapter.respond_to?(name, include_private) || super
    end
  end
end
