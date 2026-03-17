# frozen_string_literal: true

require_relative "../spec_helper"

begin
  require_relative "../../examples/support/offscreen_renderer"
  require_relative "../../examples/support/triangle_scene"
rescue StandardError => e
  DAWN_TRIANGLE_RUNTIME_ERROR = e
end

RSpec.describe "triangle integration" do
  it "renders a triangle offscreen through Dawn" do
    skip "requires Dawn shared library and render runtime: #{DAWN_TRIANGLE_RUNTIME_ERROR.message}" if defined?(DAWN_TRIANGLE_RUNTIME_ERROR)

    DawnExamples::OffscreenRenderer.with(width: 64, height: 64) do |renderer|
      DawnExamples::TriangleScene.render(renderer)
      rgb = renderer.send(:read_rgb_data, flip_y: false)
      center = pixel(rgb, x: 32, y: 32, width: 64)

      expect(center).not_to eq(DawnExamples::TriangleScene::CLEAR_RGB)
    end
  end

  def pixel(rgb, x:, y:, width:)
    offset = ((y * width) + x) * 3
    rgb.byteslice(offset, 3).bytes
  end
end
