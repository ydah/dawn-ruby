# frozen_string_literal: true

require_relative "../spec_helper"

begin
  require "dawn"
rescue StandardError => e
  DAWN_COMPUTE_RUNTIME_ERROR = e
end

RSpec.describe "compute integration" do
  it "submits a compute pass through Dawn" do
    skip "requires Dawn shared library and GPU runtime: #{DAWN_COMPUTE_RUNTIME_ERROR.message}" if defined?(DAWN_COMPUTE_RUNTIME_ERROR)

    toggles = Dawn::Toggles.new.enable(:skip_validation)
    instance = Dawn::Instance.new(toggles: toggles)
    adapter = instance.request_adapter
    device = adapter.request_device

    shader = device.create_shader_module(code: <<~WGSL)
      @compute @workgroup_size(1)
      fn main() {
      }
    WGSL

    pipeline = device.create_compute_pipeline(
      layout: :auto,
      compute: {
        module: shader,
        entry_point: "main"
      }
    )

    encoder = device.create_command_encoder
    pass = encoder.begin_compute_pass
    pass.set_pipeline(pipeline)
    pass.dispatch_workgroups(1)
    pass.end

    command_buffer = encoder.finish
    device.queue.submit([command_buffer])

    expect { device.poll(wait: true) }.not_to raise_error
  ensure
    pass&.release
    command_buffer&.release
    encoder&.release
    pipeline&.release
    shader&.release
    device&.release
    adapter&.release
    instance&.release
  end
end
