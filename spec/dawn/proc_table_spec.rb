# frozen_string_literal: true

require_relative "../spec_helper"
require "ffi"

module Dawn
  module Native
  end
end

require_relative "../../lib/dawn/native/proc_table"

RSpec.describe Dawn::Native do
  it "returns nil when no proc getter is available" do
    expect(described_class.get_procs).to be_nil
  end

  it "sets the proc table when getter and setter are available" do
    ptr = FFI::MemoryPointer.new(:pointer)

    allow(described_class).to receive(:dawn_native_GetProcs).and_return(ptr)
    allow(described_class).to receive(:dawnProcSetProcs)

    expect(described_class.set_procs!).to be(true)
    expect(described_class).to have_received(:dawnProcSetProcs).with(ptr)
  end
end
