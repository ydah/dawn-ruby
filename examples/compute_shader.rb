# frozen_string_literal: true

require "dawn"

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

device.queue.submit([encoder.finish])
device.poll(wait: true)

pipeline.release
shader.release
device.release
adapter.release
instance.release

puts "Compute pass submitted through Dawn"
