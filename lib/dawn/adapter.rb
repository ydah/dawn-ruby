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
      supported = WGPU::Native::SupportedFeatures.new
      WGPU::Native.wgpuAdapterGetFeatures(@wgpu_adapter.handle, supported)

      return [] if supported[:feature_count].zero? || supported[:features].null?

      supported[:features].read_array_of_uint32(supported[:feature_count]).map do |value|
        resolve_feature_name(value)
      end
    end

    def has_feature?(feature)
      features.include?(normalize_feature_name(feature))
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

    private

    def normalize_feature_name(feature)
      return feature if feature.is_a?(Symbol)
      return feature.to_sym if feature.is_a?(String)
      return resolve_feature_name(feature) if feature.is_a?(Integer)

      feature
    end

    def resolve_feature_name(value)
      WGPU::Native::FeatureName[value] || Dawn::FeatureNameExt.symbol_for(value)
    end
  end
end
