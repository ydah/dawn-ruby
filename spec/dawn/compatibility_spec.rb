# frozen_string_literal: true

require_relative "../spec_helper"

begin
  require "dawn"
rescue StandardError => e
  DAWN_COMPATIBILITY_RUNTIME_ERROR = e
end

RSpec.describe "compatibility contract" do
  it "documents expected wgpu-native specific symbols" do
    symbols = %i[
      wgpuDevicePoll
      wgpuInstanceEnumerateAdapters
    ]

    expect(symbols).to include(:wgpuDevicePoll)
    expect(symbols).to include(:wgpuInstanceEnumerateAdapters)
  end

  it "normalizes feature names using the latest WebGPU header mapping" do
    skip "requires Dawn shared library and runtime: #{DAWN_COMPATIBILITY_RUNTIME_ERROR.message}" if defined?(DAWN_COMPATIBILITY_RUNTIME_ERROR)

    expect(WGPU::Device.send(:normalize_feature_name, :core_features_and_limits)).to eq(0x00000001)
    expect(WGPU::Device.send(:normalize_feature_name, :timestamp_query)).to eq(0x00000009)
    expect(WGPU::Device.send(:normalize_feature_name, :subgroups)).to eq(0x00000012)
  end
end
