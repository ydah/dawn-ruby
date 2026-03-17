# frozen_string_literal: true

require_relative "../spec_helper"

module WGPU
  class AsyncTask
    def initialize(&block)
      @block = block
    end

    def value
      @block.call
    end

    def then(&block)
      self.class.new do
        block.call(value)
      end
    end
  end

  class Instance
    attr_reader :request_adapter_calls, :enumerate_adapters_calls

    def initialize
      @request_adapter_calls = []
      @enumerate_adapters_calls = []
    end

    def request_adapter(**options)
      @request_adapter_calls << options
      :wgpu_adapter
    end

    def request_adapter_async(**options)
      AsyncTask.new { request_adapter(**options) }
    end

    def enumerate_adapters(backends: nil)
      @enumerate_adapters_calls << backends
      %i[wgpu_adapter_a wgpu_adapter_b]
    end

    def enumerate_adapters_async(backends: nil)
      AsyncTask.new { enumerate_adapters(backends: backends) }
    end

    def process_events
      :processed
    end

    def release
      :released
    end
  end
end

require_relative "../../lib/dawn/adapter"
require_relative "../../lib/dawn/instance"

RSpec.describe Dawn::Instance do
  let(:wgpu_instance) { WGPU::Instance.new }
  subject(:instance) do
    described_class.allocate.tap do |obj|
      obj.instance_variable_set(:@wgpu_instance, wgpu_instance)
    end
  end

  it "wraps request_adapter in Dawn::Adapter" do
    adapter = instance.request_adapter(backend: :metal)

    expect(adapter).to be_a(Dawn::Adapter)
    expect(adapter.wgpu_adapter).to eq(:wgpu_adapter)
    expect(wgpu_instance.request_adapter_calls).to eq([{ backend: :metal }])
  end

  it "wraps request_adapter_async results in Dawn::Adapter" do
    adapter = instance.request_adapter_async(backend: :vulkan).value

    expect(adapter).to be_a(Dawn::Adapter)
    expect(adapter.wgpu_adapter).to eq(:wgpu_adapter)
    expect(wgpu_instance.request_adapter_calls).to eq([{ backend: :vulkan }])
  end

  it "wraps enumerate_adapters in Dawn::Adapter instances" do
    adapters = instance.enumerate_adapters(backends: :metal)

    expect(adapters.map(&:wgpu_adapter)).to eq(%i[wgpu_adapter_a wgpu_adapter_b])
    expect(wgpu_instance.enumerate_adapters_calls).to eq([:metal])
  end

  it "wraps enumerate_adapters_async results in Dawn::Adapter instances" do
    adapters = instance.enumerate_adapters_async(backends: :vulkan).value

    expect(adapters.map(&:wgpu_adapter)).to eq(%i[wgpu_adapter_a wgpu_adapter_b])
    expect(wgpu_instance.enumerate_adapters_calls).to eq([:vulkan])
  end
end
