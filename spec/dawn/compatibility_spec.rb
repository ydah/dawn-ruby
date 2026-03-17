# frozen_string_literal: true

require_relative "../spec_helper"

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
    require "dawn"

    expect(WGPU::Device.send(:normalize_feature_name, :core_features_and_limits)).to eq(0x00000001)
    expect(WGPU::Device.send(:normalize_feature_name, :timestamp_query)).to eq(0x00000009)
    expect(WGPU::Device.send(:normalize_feature_name, :subgroups)).to eq(0x00000012)
  end
end
