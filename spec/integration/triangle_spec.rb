# frozen_string_literal: true

require_relative "../spec_helper"

begin
  require_relative "../../examples/support/offscreen_renderer"
rescue StandardError => e
  DAWN_TRIANGLE_RUNTIME_ERROR = e
end

RSpec.describe "triangle integration" do
  it "renders a triangle offscreen through Dawn" do
    skip "requires Dawn shared library and render runtime: #{DAWN_TRIANGLE_RUNTIME_ERROR.message}" if defined?(DAWN_TRIANGLE_RUNTIME_ERROR)

    clear_rgb = [13, 15, 25]

    DawnExamples::OffscreenRenderer.with(width: 64, height: 64) do |renderer|
      device = renderer.device

      shader = device.create_shader_module(code: <<~WGSL)
        struct VertexOutput {
          @builtin(position) position: vec4<f32>,
          @location(0) color: vec3<f32>,
        };

        @vertex
        fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOutput {
          var positions = array<vec2<f32>, 3>(
            vec2<f32>(-0.70, -0.62),
            vec2<f32>( 0.70, -0.62),
            vec2<f32>( 0.00,  0.75)
          );
          var colors = array<vec3<f32>, 3>(
            vec3<f32>(1.00, 0.25, 0.30),
            vec3<f32>(0.20, 0.90, 0.40),
            vec3<f32>(0.20, 0.55, 1.00)
          );

          var output: VertexOutput;
          output.position = vec4<f32>(positions[vertex_index], 0.0, 1.0);
          output.color = colors[vertex_index];
          return output;
        }

        @fragment
        fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
          return vec4<f32>(input.color, 1.0);
        }
      WGSL

      pipeline = device.create_render_pipeline(
        layout: :auto,
        vertex: {
          module: shader,
          entry_point: "vs_main"
        },
        fragment: {
          module: shader,
          entry_point: "fs_main",
          targets: [{ format: renderer.color_format }]
        }
      )

      renderer.render(clear_color: { r: 0.05, g: 0.06, b: 0.10, a: 1.0 }) do |pass|
        pass.set_pipeline(pipeline)
        pass.draw(3)
      end

      rgb = renderer.send(:read_rgb_data, flip_y: false)
      center = pixel(rgb, x: 32, y: 32, width: 64)

      expect(center).not_to eq(clear_rgb)
    ensure
      pipeline&.release
      shader&.release
    end
  end

  def pixel(rgb, x:, y:, width:)
    offset = ((y * width) + x) * 3
    rgb.byteslice(offset, 3).bytes
  end
end
