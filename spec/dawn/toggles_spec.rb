# frozen_string_literal: true

require_relative "../spec_helper"

begin
  require "dawn"
rescue StandardError => e
  DAWN_TOGGLES_RUNTIME_ERROR = e
end

RSpec.describe Dawn::Toggles do
  before do
    skip "requires Dawn shared library and runtime: #{DAWN_TOGGLES_RUNTIME_ERROR.message}" if defined?(DAWN_TOGGLES_RUNTIME_ERROR)
  end

  it "builds a toggles descriptor" do
    toggles = described_class.new.enable(:skip_validation).disable(:turn_off_vsync)
    descriptor = toggles.to_descriptor

    expect(descriptor[:enabled_toggle_count]).to eq(1)
    expect(descriptor[:disabled_toggle_count]).to eq(1)
  end

  it "accepts string toggles" do
    toggles = described_class.new.enable("custom_toggle")
    descriptor = toggles.to_descriptor

    expect(descriptor[:enabled_toggle_count]).to eq(1)
  end
end
