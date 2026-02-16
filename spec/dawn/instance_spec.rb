# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe "Dawn::Instance" do
  it "is defined" do
    expect(defined?(Dawn::Instance)).to satisfy { |v| [nil, "constant"].include?(v) }
  end
end
