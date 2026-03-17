# frozen_string_literal: true

module DawnExamples
  module TriangleScene
    CLEAR_RGB = [13, 15, 25].freeze
    CLEAR_COLOR = {
      r: CLEAR_RGB[0] / 255.0,
      g: CLEAR_RGB[1] / 255.0,
      b: CLEAR_RGB[2] / 255.0,
      a: 1.0
    }.freeze

    SHADER = <<~WGSL
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

    class << self
      def render(renderer, clear_color: CLEAR_COLOR)
        shader = renderer.device.create_shader_module(code: SHADER)
        pipeline = renderer.device.create_render_pipeline(
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

        renderer.render(clear_color: clear_color) do |pass|
          pass.set_pipeline(pipeline)
          pass.draw(3)
        end
      ensure
        pipeline&.release
        shader&.release
      end
    end
  end
end
