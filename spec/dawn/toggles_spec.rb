# frozen_string_literal: true

require_relative "../spec_helper"
require "ffi"

module WGPU
  module Native
    SType = FFI::Enum.new([:invalid, 0])

    class ChainedStruct < FFI::Struct
      layout :next, :pointer,
             :s_type, SType
    end
  end
end

require_relative "../../lib/dawn/native/enums_ext"
require_relative "../../lib/dawn/native/structs_ext"
require_relative "../../lib/dawn/toggles"

RSpec.describe Dawn::Toggles do
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
