# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../lib/dawn/native/enums_ext"

RSpec.describe Dawn::FeatureNameExt do
  it "maps latest WebGPU header feature values to symbols" do
    expect(described_class.symbol_for(0x00000001)).to eq(:core_features_and_limits)
    expect(described_class.symbol_for(0x00000009)).to eq(:timestamp_query)
    expect(described_class.symbol_for(0x00000012)).to eq(:subgroups)
    expect(described_class.symbol_for(0x00000016)).to eq(:texture_component_swizzle)
  end

  it "maps Dawn extension feature values to symbols" do
    expect(described_class.symbol_for(described_class::IMPLICIT_DEVICE_SYNCHRONIZATION)).to eq(
      :implicit_device_synchronization
    )
  end

  it "maps latest WebGPU header feature names back to values" do
    expect(described_class.value_for(:core_features_and_limits)).to eq(0x00000001)
    expect(described_class.value_for("timestamp_query")).to eq(0x00000009)
    expect(described_class.value_for(:subgroups)).to eq(0x00000012)
    expect(described_class.value_for(:texture_component_swizzle)).to eq(0x00000016)
  end

  it "maps Dawn extension feature names back to values" do
    expect(described_class.value_for(:implicit_device_synchronization)).to eq(
      described_class::IMPLICIT_DEVICE_SYNCHRONIZATION
    )
  end
end
