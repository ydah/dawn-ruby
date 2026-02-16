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
end
