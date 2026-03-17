# frozen_string_literal: true

require_relative "support/offscreen_renderer"
require_relative "support/triangle_scene"

WIDTH = 800
HEIGHT = 600
OUTPUT_PATH = File.expand_path("output/triangle_2d.ppm", __dir__)

DawnExamples::OffscreenRenderer.with(width: WIDTH, height: HEIGHT) do |renderer|
  DawnExamples::TriangleScene.render(renderer)
  renderer.save_to_ppm(OUTPUT_PATH)
  puts "Rendered #{OUTPUT_PATH}"
end
