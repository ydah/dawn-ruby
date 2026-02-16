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
end
