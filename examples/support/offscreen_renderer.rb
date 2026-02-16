# frozen_string_literal: true

require "dawn"
require "fileutils"

module DawnExamples
  class OffscreenRenderer
    BYTES_PER_PIXEL = 4
    BYTES_PER_ROW_ALIGNMENT = 256
    DEFAULT_CLEAR_COLOR = { r: 0.02, g: 0.03, b: 0.05, a: 1.0 }.freeze

    attr_reader :width, :height, :instance, :adapter, :device
    attr_reader :color_texture, :color_view, :color_format
    attr_reader :depth_texture, :depth_view, :depth_format

    DEPTH_PROBE_SHADER = <<~WGSL
      @vertex
      fn vs_main(@builtin(vertex_index) vertex_index: u32) -> @builtin(position) vec4<f32> {
        var positions = array<vec2<f32>, 3>(
          vec2<f32>(-1.0, -1.0),
          vec2<f32>( 3.0, -1.0),
          vec2<f32>(-1.0,  3.0)
        );
        return vec4<f32>(positions[vertex_index], 0.0, 1.0);
      }

      @fragment
      fn fs_main() -> @location(0) vec4<f32> {
        return vec4<f32>(0.0, 0.0, 0.0, 1.0);
      }
    WGSL

    def self.with(width:, height:, with_depth: false, color_format: :bgra8_unorm, depth_format: nil, toggles: nil)
      renderer = new(
        width: width,
        height: height,
        with_depth: with_depth,
        color_format: color_format,
        depth_format: depth_format,
        toggles: toggles
      )
      yield renderer
    ensure
      renderer&.release
    end

    def initialize(width:, height:, with_depth: false, color_format: :bgra8_unorm, depth_format: nil, toggles: nil)
      @width = width
      @height = height
      @color_format = color_format
      @depth_format = nil
      @released = false

      @instance = toggles ? Dawn::Instance.new(toggles: toggles) : Dawn::Instance.new
      @adapter = @instance.request_adapter
      @device = @adapter.request_device

      @color_texture = @device.create_texture(
        size: { width: width, height: height, depth_or_array_layers: 1 },
        format: color_format,
        usage: [:render_attachment, :copy_src]
      )
      @color_view = @color_texture.create_view

      if with_depth
        @depth_format = resolve_depth_format(preferred: depth_format)
        @depth_texture = @device.create_texture(
          size: { width: width, height: height, depth_or_array_layers: 1 },
          format: @depth_format,
          usage: [:render_attachment]
        )
        @depth_view = @depth_texture.create_view
      else
        @depth_texture = nil
        @depth_view = nil
      end
    end

    def render(clear_color: DEFAULT_CLEAR_COLOR, clear_depth: 1.0)
      encoder = @device.create_command_encoder
      pass = encoder.begin_render_pass(
        color_attachments: [{
          view: @color_view,
          load_op: :clear,
          store_op: :store,
          clear_value: clear_color
        }],
        depth_stencil_attachment: depth_attachment(clear_depth)
      )

      yield pass
      pass.end

      command_buffer = encoder.finish
      @device.queue.submit([command_buffer])
      @device.poll(wait: true)
    ensure
      pass&.release
      command_buffer&.release
      encoder&.release
    end

    def save_to_ppm(output_path, flip_y: false)
      rgb_data = read_rgb_data(flip_y: flip_y)
      header = "P6\n#{@width} #{@height}\n255\n"

      FileUtils.mkdir_p(File.dirname(output_path))
      File.binwrite(output_path, header + rgb_data)
      output_path
    end

    def release
      return if @released
      @released = true

      @depth_view&.release
      @depth_texture&.release
      @color_view&.release
      @color_texture&.release

      @device&.release
      @adapter&.release
      @instance&.release
    end

    private

    def depth_attachment(clear_depth)
      return nil unless @depth_view

      {
        view: @depth_view,
        depth_load_op: :clear,
        depth_store_op: :store,
        depth_clear_value: clear_depth
      }
    end

    def read_rgb_data(flip_y:)
      bytes_per_row = aligned_bytes_per_row(@width)
      buffer_size = bytes_per_row * @height

      readback_buffer = @device.create_buffer(
        size: buffer_size,
        usage: [:copy_dst, :map_read]
      )

      encoder = @device.create_command_encoder
      encoder.copy_texture_to_buffer(
        source: {
          texture: @color_texture
        },
        destination: {
          buffer: readback_buffer,
          offset: 0,
          bytes_per_row: bytes_per_row,
          rows_per_image: @height
        },
        copy_size: {
          width: @width,
          height: @height,
          depth_or_array_layers: 1
        }
      )
      command_buffer = encoder.finish
      @device.queue.submit([command_buffer])
      @device.poll(wait: true)

      readback_buffer.map_sync(:read)
      raw_data = readback_buffer.read_mapped_data
      readback_buffer.unmap

      extract_rgb(raw_data, bytes_per_row: bytes_per_row, flip_y: flip_y)
    ensure
      readback_buffer&.release
      command_buffer&.release
      encoder&.release
    end

    def extract_rgb(raw_data, bytes_per_row:, flip_y:)
      rgb = String.new(encoding: Encoding::BINARY)
      @height.times do |row|
        source_row = flip_y ? (@height - 1 - row) : row
        row_offset = source_row * bytes_per_row

        @width.times do |x|
          pixel_offset = row_offset + (x * BYTES_PER_PIXEL)
          append_rgb_bytes(rgb, raw_data, pixel_offset)
        end
      end
      rgb
    end

    def append_rgb_bytes(rgb, raw_data, pixel_offset)
      if @color_format == :bgra8_unorm || @color_format == :bgra8_unorm_srgb
        rgb << raw_data.getbyte(pixel_offset + 2)
        rgb << raw_data.getbyte(pixel_offset + 1)
        rgb << raw_data.getbyte(pixel_offset)
        return
      end

      rgb << raw_data.getbyte(pixel_offset)
      rgb << raw_data.getbyte(pixel_offset + 1)
      rgb << raw_data.getbyte(pixel_offset + 2)
    end

    def aligned_bytes_per_row(width)
      unaligned = width * BYTES_PER_PIXEL
      ((unaligned + BYTES_PER_ROW_ALIGNMENT - 1) / BYTES_PER_ROW_ALIGNMENT) * BYTES_PER_ROW_ALIGNMENT
    end

    def resolve_depth_format(preferred:)
      candidates = [
        preferred,
        :depth24_plus,
        :depth32_float,
        :depth16_unorm,
        :bc1_rgba_unorm_srgb,
        :bc2_rgba_unorm,
        :bc2_rgba_unorm_srgb,
        :bc3_rgba_unorm
      ].compact.uniq

      candidates.each do |format|
        return format if depth_format_supported?(format)
      end

      raise WGPU::PipelineError, "No compatible depth format found for this Dawn runtime"
    end

    def depth_format_supported?(format)
      shader = @device.create_shader_module(code: DEPTH_PROBE_SHADER)
      pipeline = @device.create_render_pipeline(
        layout: :auto,
        vertex: {
          module: shader,
          entry_point: "vs_main"
        },
        depth_stencil: {
          format: format,
          depth_write_enabled: true,
          depth_compare: :less
        },
        fragment: {
          module: shader,
          entry_point: "fs_main",
          targets: [{ format: @color_format }]
        }
      )
      true
    rescue StandardError
      false
    ensure
      pipeline&.release
      shader&.release
    end
  end
end
