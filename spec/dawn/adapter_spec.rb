# frozen_string_literal: true

require_relative "../spec_helper"

begin
  require "dawn"
rescue StandardError => e
  DAWN_ADAPTER_RUNTIME_ERROR = e
end

RSpec.describe Dawn::Adapter do
  let(:wgpu_adapter) do
    instance_double("WGPU::Adapter", handle: FFI::Pointer::NULL, info: { backend_type: :metal })
  end
  let(:feature_values) do
    [
      WGPU::Native::FeatureName[:depth_clip_control],
      Dawn::FeatureNameExt::IMPLICIT_DEVICE_SYNCHRONIZATION,
      999_999
    ]
  end
  let(:feature_ptr) do
    FFI::MemoryPointer.new(:uint32, feature_values.length).tap do |ptr|
      ptr.write_array_of_uint32(feature_values)
    end
  end

  subject(:adapter) { described_class.new(wgpu_adapter) }

  before do
    skip "requires Dawn shared library and runtime: #{DAWN_ADAPTER_RUNTIME_ERROR.message}" if defined?(DAWN_ADAPTER_RUNTIME_ERROR)

    allow(WGPU::Native).to receive(:wgpuAdapterGetFeatures) do |_handle, supported|
      supported[:feature_count] = feature_values.length
      supported[:features] = feature_ptr
    end
  end

  it "maps Dawn extension feature ids to symbols" do
    expect(adapter.features).to eq([
      :depth_clip_control,
      :implicit_device_synchronization,
      :feature_999999
    ])
  end

  it "checks feature membership using Dawn feature names" do
    expect(adapter.has_feature?(:implicit_device_synchronization)).to be(true)
    expect(adapter.has_feature?("feature_999999")).to be(true)
    expect(adapter.has_feature?(:non_existent_feature)).to be(false)
  end
end
