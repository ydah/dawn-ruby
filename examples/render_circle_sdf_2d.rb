# frozen_string_literal: true

require_relative "support/offscreen_renderer"

WIDTH = 800
HEIGHT = 600
OUTPUT_PATH = File.expand_path("output/circle_sdf_2d.ppm", __dir__)

DawnExamples::OffscreenRenderer.with(width: WIDTH, height: HEIGHT) do |renderer|
  device = renderer.device

  shader = device.create_shader_module(code: <<~WGSL)
    struct VertexOutput {
      @builtin(position) position: vec4<f32>,
      @location(0) uv: vec2<f32>,
    };

    @vertex
    fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOutput {
      var positions = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>( 3.0, -1.0),
        vec2<f32>(-1.0,  3.0)
      );

      var output: VertexOutput;
      let position = positions[vertex_index];
      output.position = vec4<f32>(position, 0.0, 1.0);
      output.uv = position * 0.5 + vec2<f32>(0.5, 0.5);
      return output;
    }

    fn grid_line(value: f32, scale: f32) -> f32 {
      let cell = abs(fract(value * scale) - 0.5);
      return smoothstep(0.495, 0.475, cell);
    }

    @fragment
    fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
      let center = vec2<f32>(0.5, 0.5);
      let dist = distance(input.uv, center);

      let circle_fill = 1.0 - smoothstep(0.30, 0.33, dist);
      let circle_ring = smoothstep(0.33, 0.35, dist) - smoothstep(0.38, 0.40, dist);
      let grid = max(grid_line(input.uv.x, 24.0), grid_line(input.uv.y, 24.0));

      let background = vec3<f32>(0.03, 0.07, 0.13);
      let fill_color = vec3<f32>(0.08, 0.72, 0.95) * circle_fill;
      let ring_color = vec3<f32>(0.98, 0.91, 0.38) * circle_ring;
      let grid_color = vec3<f32>(0.12, 0.14, 0.18) * grid;

      return vec4<f32>(background + fill_color + ring_color + grid_color, 1.0);
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

  renderer.render do |pass|
    pass.set_pipeline(pipeline)
    pass.draw(3)
  end

  renderer.save_to_ppm(OUTPUT_PATH)
  puts "Rendered #{OUTPUT_PATH}"
ensure
  pipeline&.release
  shader&.release
end
