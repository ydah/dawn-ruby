# frozen_string_literal: true

require_relative "support/offscreen_renderer"

WIDTH = 960
HEIGHT = 720
OUTPUT_PATH = File.expand_path("output/cube_3d.ppm", __dir__)

DawnExamples::OffscreenRenderer.with(width: WIDTH, height: HEIGHT, with_depth: true) do |renderer|
  device = renderer.device

  shader = device.create_shader_module(code: <<~WGSL)
    struct VertexOutput {
      @builtin(position) position: vec4<f32>,
      @location(0) color: vec3<f32>,
    };

    fn rotate_cube(position: vec3<f32>) -> vec3<f32> {
      let angle_y = 0.6632251158; // 38 deg
      let angle_x = -0.4188790205; // -24 deg

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
      let fov = 1.0471975512; // 60 deg
      let near = 0.1;
      let far = 100.0;
      let f = 1.0 / tan(fov * 0.5);

      let view = vec3<f32>(position.x, position.y, position.z - 4.6);
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
      var positions = array<vec3<f32>, 36>(
        vec3<f32>(-1.0, -1.0,  1.0), vec3<f32>( 1.0, -1.0,  1.0), vec3<f32>( 1.0,  1.0,  1.0),
        vec3<f32>(-1.0, -1.0,  1.0), vec3<f32>( 1.0,  1.0,  1.0), vec3<f32>(-1.0,  1.0,  1.0),

        vec3<f32>( 1.0, -1.0, -1.0), vec3<f32>(-1.0, -1.0, -1.0), vec3<f32>(-1.0,  1.0, -1.0),
        vec3<f32>( 1.0, -1.0, -1.0), vec3<f32>(-1.0,  1.0, -1.0), vec3<f32>( 1.0,  1.0, -1.0),

        vec3<f32>(-1.0, -1.0, -1.0), vec3<f32>(-1.0, -1.0,  1.0), vec3<f32>(-1.0,  1.0,  1.0),
        vec3<f32>(-1.0, -1.0, -1.0), vec3<f32>(-1.0,  1.0,  1.0), vec3<f32>(-1.0,  1.0, -1.0),

        vec3<f32>( 1.0, -1.0,  1.0), vec3<f32>( 1.0, -1.0, -1.0), vec3<f32>( 1.0,  1.0, -1.0),
        vec3<f32>( 1.0, -1.0,  1.0), vec3<f32>( 1.0,  1.0, -1.0), vec3<f32>( 1.0,  1.0,  1.0),

        vec3<f32>(-1.0,  1.0,  1.0), vec3<f32>( 1.0,  1.0,  1.0), vec3<f32>( 1.0,  1.0, -1.0),
        vec3<f32>(-1.0,  1.0,  1.0), vec3<f32>( 1.0,  1.0, -1.0), vec3<f32>(-1.0,  1.0, -1.0),

        vec3<f32>(-1.0, -1.0, -1.0), vec3<f32>( 1.0, -1.0, -1.0), vec3<f32>( 1.0, -1.0,  1.0),
        vec3<f32>(-1.0, -1.0, -1.0), vec3<f32>( 1.0, -1.0,  1.0), vec3<f32>(-1.0, -1.0,  1.0)
      );

      var colors = array<vec3<f32>, 36>(
        vec3<f32>(1.00, 0.26, 0.22), vec3<f32>(1.00, 0.26, 0.22), vec3<f32>(1.00, 0.26, 0.22),
        vec3<f32>(1.00, 0.26, 0.22), vec3<f32>(1.00, 0.26, 0.22), vec3<f32>(1.00, 0.26, 0.22),

        vec3<f32>(0.14, 0.78, 1.00), vec3<f32>(0.14, 0.78, 1.00), vec3<f32>(0.14, 0.78, 1.00),
        vec3<f32>(0.14, 0.78, 1.00), vec3<f32>(0.14, 0.78, 1.00), vec3<f32>(0.14, 0.78, 1.00),

        vec3<f32>(0.28, 0.92, 0.40), vec3<f32>(0.28, 0.92, 0.40), vec3<f32>(0.28, 0.92, 0.40),
        vec3<f32>(0.28, 0.92, 0.40), vec3<f32>(0.28, 0.92, 0.40), vec3<f32>(0.28, 0.92, 0.40),

        vec3<f32>(1.00, 0.66, 0.22), vec3<f32>(1.00, 0.66, 0.22), vec3<f32>(1.00, 0.66, 0.22),
        vec3<f32>(1.00, 0.66, 0.22), vec3<f32>(1.00, 0.66, 0.22), vec3<f32>(1.00, 0.66, 0.22),

        vec3<f32>(0.95, 0.36, 1.00), vec3<f32>(0.95, 0.36, 1.00), vec3<f32>(0.95, 0.36, 1.00),
        vec3<f32>(0.95, 0.36, 1.00), vec3<f32>(0.95, 0.36, 1.00), vec3<f32>(0.95, 0.36, 1.00),

        vec3<f32>(0.35, 0.52, 1.00), vec3<f32>(0.35, 0.52, 1.00), vec3<f32>(0.35, 0.52, 1.00),
        vec3<f32>(0.35, 0.52, 1.00), vec3<f32>(0.35, 0.52, 1.00), vec3<f32>(0.35, 0.52, 1.00)
      );

      var output: VertexOutput;
      let world = rotate_cube(positions[vertex_index]);
      output.position = perspective_project(world);
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
    primitive: {
      topology: :triangle_list,
      cull_mode: :back
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

  renderer.render(clear_color: { r: 0.02, g: 0.03, b: 0.05, a: 1.0 }, clear_depth: 1.0) do |pass|
    pass.set_pipeline(pipeline)
    pass.draw(36)
  end

  renderer.save_to_ppm(OUTPUT_PATH)
  puts "Rendered #{OUTPUT_PATH}"
ensure
  pipeline&.release
  shader&.release
end
