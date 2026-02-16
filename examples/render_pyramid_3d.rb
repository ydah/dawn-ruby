# frozen_string_literal: true

require_relative "support/offscreen_renderer"

WIDTH = 960
HEIGHT = 720
OUTPUT_PATH = File.expand_path("output/pyramid_3d.ppm", __dir__)

DawnExamples::OffscreenRenderer.with(width: WIDTH, height: HEIGHT, with_depth: true) do |renderer|
  device = renderer.device

  shader = device.create_shader_module(code: <<~WGSL)
    struct VertexOutput {
      @builtin(position) position: vec4<f32>,
      @location(0) color: vec3<f32>,
      @location(1) height: f32,
    };

    fn rotate_pyramid(position: vec3<f32>) -> vec3<f32> {
      let angle_y = -0.7679448709; // -44 deg
      let angle_x = 0.3141592653; // 18 deg

      let cy = cos(angle_y);
      let sy = sin(angle_y);
      let cx = cos(angle_x);
      let sx = sin(angle_x);

      let yawed = vec3<f32>(
        position.x * cy + position.z * sy,
        position.y,
        -position.x * sy + position.z * cy
      );

      return vec3<f32>(
        yawed.x,
        yawed.y * cx - yawed.z * sx,
        yawed.y * sx + yawed.z * cx
      );
    }

    fn perspective_project(position: vec3<f32>) -> vec4<f32> {
      let aspect = 960.0 / 720.0;
      let fov = 0.9424777961; // 54 deg
      let near = 0.1;
      let far = 100.0;
      let f = 1.0 / tan(fov * 0.5);

      let view = vec3<f32>(position.x, position.y - 0.20, position.z - 5.0);
      let clip_z = view.z * (far / (near - far)) + (far * near / (near - far));
      let clip_w = -view.z;

      return vec4<f32>(
        view.x * (f / aspect),
        view.y * f,
        clip_z,
        clip_w
      );
    }

    @vertex
    fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOutput {
      var positions = array<vec3<f32>, 18>(
        vec3<f32>(-1.2, -1.0, -1.2), vec3<f32>( 1.2, -1.0, -1.2), vec3<f32>( 1.2, -1.0,  1.2),
        vec3<f32>(-1.2, -1.0, -1.2), vec3<f32>( 1.2, -1.0,  1.2), vec3<f32>(-1.2, -1.0,  1.2),

        vec3<f32>(-1.2, -1.0, -1.2), vec3<f32>( 1.2, -1.0, -1.2), vec3<f32>( 0.0,  1.3,  0.0),
        vec3<f32>( 1.2, -1.0, -1.2), vec3<f32>( 1.2, -1.0,  1.2), vec3<f32>( 0.0,  1.3,  0.0),
        vec3<f32>( 1.2, -1.0,  1.2), vec3<f32>(-1.2, -1.0,  1.2), vec3<f32>( 0.0,  1.3,  0.0),
        vec3<f32>(-1.2, -1.0,  1.2), vec3<f32>(-1.2, -1.0, -1.2), vec3<f32>( 0.0,  1.3,  0.0)
      );

      var colors = array<vec3<f32>, 18>(
        vec3<f32>(0.74, 0.74, 0.74), vec3<f32>(0.74, 0.74, 0.74), vec3<f32>(0.74, 0.74, 0.74),
        vec3<f32>(0.74, 0.74, 0.74), vec3<f32>(0.74, 0.74, 0.74), vec3<f32>(0.74, 0.74, 0.74),

        vec3<f32>(0.95, 0.36, 0.18), vec3<f32>(0.95, 0.36, 0.18), vec3<f32>(0.95, 0.36, 0.18),
        vec3<f32>(0.18, 0.78, 0.33), vec3<f32>(0.18, 0.78, 0.33), vec3<f32>(0.18, 0.78, 0.33),
        vec3<f32>(0.16, 0.62, 0.96), vec3<f32>(0.16, 0.62, 0.96), vec3<f32>(0.16, 0.62, 0.96),
        vec3<f32>(0.96, 0.84, 0.26), vec3<f32>(0.96, 0.84, 0.26), vec3<f32>(0.96, 0.84, 0.26)
      );

      var output: VertexOutput;
      let rotated = rotate_pyramid(positions[vertex_index]);
      output.position = perspective_project(rotated);
      output.color = colors[vertex_index];
      output.height = positions[vertex_index].y;
      return output;
    }

    @fragment
    fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
      let horizon = smoothstep(-1.0, 1.3, input.height);
      let lit = mix(input.color * 0.55, input.color, horizon);
      return vec4<f32>(lit, 1.0);
    }
  WGSL

  pipeline = device.create_render_pipeline(
    layout: :auto,
    vertex: {
      module: shader,
      entry_point: "vs_main"
    },
    primitive: {
      topology: :triangle_list,
      cull_mode: :none
    },
    depth_stencil: {
      format: renderer.depth_format,
      depth_write_enabled: true,
      depth_compare: :less
    },
    fragment: {
      module: shader,
      entry_point: "fs_main",
      targets: [{ format: renderer.color_format }]
    }
  )

  renderer.render(clear_color: { r: 0.03, g: 0.03, b: 0.04, a: 1.0 }, clear_depth: 1.0) do |pass|
    pass.set_pipeline(pipeline)
    pass.draw(18)
  end

  renderer.save_to_ppm(OUTPUT_PATH)
  puts "Rendered #{OUTPUT_PATH}"
ensure
  pipeline&.release
  shader&.release
end
