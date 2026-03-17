# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../lib/dawn/adapter"

RSpec.describe Dawn::Adapter do
  let(:wgpu_adapter) do
    instance_double(
      "WGPU::Adapter",
      info: { backend_type: :metal },
      features: [:core_features_and_limits, :subgroups],
      has_feature?: true
    )
  end

  subject(:adapter) { described_class.new(wgpu_adapter) }

  it "delegates features to the wrapped adapter" do
    expect(adapter.features).to eq([:core_features_and_limits, :subgroups])
  end

  it "delegates feature checks to the wrapped adapter" do
    expect(adapter.has_feature?(:subgroups)).to be(true)
    expect(wgpu_adapter).to have_received(:has_feature?).with(:subgroups)
  end
end
