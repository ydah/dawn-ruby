# frozen_string_literal: true

require_relative "support/offscreen_renderer"

WIDTH = 800
HEIGHT = 600
OUTPUT_PATH = File.expand_path("output/blended_quads_2d.ppm", __dir__)

DawnExamples::OffscreenRenderer.with(width: WIDTH, height: HEIGHT) do |renderer|
  device = renderer.device

  shader = device.create_shader_module(code: <<~WGSL)
    struct VertexOutput {
      @builtin(position) position: vec4<f32>,
      @location(0) color: vec4<f32>,
    };

    @vertex
    fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOutput {
      var positions = array<vec2<f32>, 12>(
        vec2<f32>(-0.65, -0.55),
        vec2<f32>( 0.20, -0.55),
        vec2<f32>( 0.20,  0.35),
        vec2<f32>(-0.65, -0.55),
        vec2<f32>( 0.20,  0.35),
        vec2<f32>(-0.65,  0.35),

        vec2<f32>(-0.20, -0.35),
        vec2<f32>( 0.65, -0.35),
        vec2<f32>( 0.65,  0.55),
        vec2<f32>(-0.20, -0.35),
        vec2<f32>( 0.65,  0.55),
        vec2<f32>(-0.20,  0.55)
      );
      var colors = array<vec4<f32>, 12>(
        vec4<f32>(1.00, 0.20, 0.15, 0.62),
        vec4<f32>(1.00, 0.20, 0.15, 0.62),
        vec4<f32>(1.00, 0.20, 0.15, 0.62),
        vec4<f32>(1.00, 0.20, 0.15, 0.62),
        vec4<f32>(1.00, 0.20, 0.15, 0.62),
        vec4<f32>(1.00, 0.20, 0.15, 0.62),

        vec4<f32>(0.10, 0.68, 0.95, 0.62),
        vec4<f32>(0.10, 0.68, 0.95, 0.62),
        vec4<f32>(0.10, 0.68, 0.95, 0.62),
        vec4<f32>(0.10, 0.68, 0.95, 0.62),
        vec4<f32>(0.10, 0.68, 0.95, 0.62),
        vec4<f32>(0.10, 0.68, 0.95, 0.62)
      );

      var output: VertexOutput;
      output.position = vec4<f32>(positions[vertex_index], 0.0, 1.0);
      output.color = colors[vertex_index];
      return output;
    }

    @fragment
    fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
      return input.color;
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
      targets: [{
        format: renderer.color_format,
        blend: {
          color: {
            operation: :add,
            src_factor: :src_alpha,
            dst_factor: :one_minus_src_alpha
          },
          alpha: {
            operation: :add,
            src_factor: :one,
            dst_factor: :one_minus_src_alpha
          }
        }
      }]
    }
  )

  renderer.render(clear_color: { r: 0.08, g: 0.08, b: 0.10, a: 1.0 }) do |pass|
    pass.set_pipeline(pipeline)
    pass.draw(12)
  end

  renderer.save_to_ppm(OUTPUT_PATH)
  puts "Rendered #{OUTPUT_PATH}"
ensure
  pipeline&.release
  shader&.release
end
