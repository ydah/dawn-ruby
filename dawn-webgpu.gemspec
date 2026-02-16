# frozen_string_literal: true

require_relative "lib/dawn/version"

Gem::Specification.new do |spec|
  spec.name = "dawn-webgpu"
  spec.version = Dawn::VERSION
  spec.authors = ["Yudai Takada"]
  spec.email = ["t.yudai92@gmail.com"]

  spec.summary = "Ruby bindings for Google Dawn WebGPU"
  spec.description = "Dawn-specific WebGPU extensions for Ruby, built on top of the wgpu gem."
  spec.homepage = "https://github.com/ydah/dawn-webgpu"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir.glob("{lib,ext,spec,examples}/**/*", File::FNM_DOTMATCH).reject do |path|
    path.end_with?(".", "..")
  end + ["README.md", "COMPATIBILITY.md", "Gemfile", "Rakefile", "dawn-webgpu.gemspec"]

  spec.require_paths = ["lib"]
  spec.extensions = ["ext/dawn/extconf.rb"]

  spec.add_dependency "ffi", "~> 1.15"
  spec.add_dependency "wgpu", "~> 1.1"
end
