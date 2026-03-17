# frozen_string_literal: true

require_relative "support/offscreen_renderer"
require_relative "support/triangle_scene"

WIDTH = 512
HEIGHT = 512
OUTPUT_PATH = File.expand_path("output/hello_triangle.ppm", __dir__)

DawnExamples::OffscreenRenderer.with(width: WIDTH, height: HEIGHT) do |renderer|
  DawnExamples::TriangleScene.render(renderer)
  renderer.save_to_ppm(OUTPUT_PATH)
  puts "Rendered hello triangle to #{OUTPUT_PATH} on #{renderer.adapter.summary}"
end
