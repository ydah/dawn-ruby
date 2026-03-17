# frozen_string_literal: true

require "tmpdir"
require_relative "../spec_helper"
require_relative "../../lib/dawn/version"
require_relative "../../lib/dawn/errors"
require_relative "../../lib/dawn/upstream"
require_relative "../../lib/dawn/loader"

RSpec.describe Dawn::Loader do
  around do |example|
    original = ENV.to_h
    begin
      example.run
    ensure
      ENV.replace(original)
    end
  end

  it "prefers DAWN_LIBRARY_PATH when it exists" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "libdawn.so")
      File.write(path, "")
      ENV["DAWN_LIBRARY_PATH"] = path

      expect(described_class.resolve_library_path).to eq(path)
    end
  end

  it "respects WGPU_LIB_PATH when it points to a Dawn library" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "libdawn.so")
      File.write(path, "")
      ENV["WGPU_LIB_PATH"] = path

      described_class.activate!

      expect(ENV["WGPU_LIB_PATH"]).to eq(path)
      expect(described_class.library_path).to eq(path)
    end
  end

  it "searches the bundled ext directory relative to the gem root" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        roots = described_class.send(:search_roots)
        expected = File.expand_path("../../ext/dawn/lib", __dir__)

        expect(roots).to include(expected)
        expect(roots).not_to include(File.join(dir, "ext", "dawn", "lib"))
      end
    end
  end

  it "shares the upstream cache directory" do
    expect(described_class.cache_dir).to eq(Dawn::Upstream.cache_dir)
  end

  it "raises a Dawn::LoadError when no candidates exist" do
    ENV.delete("DAWN_LIBRARY_PATH")
    ENV.delete("DAWN_LIBRARY_DIR")

    allow(described_class).to receive(:cache_dir).and_return("/tmp/definitely-missing-dawn-cache")
    allow(described_class).to receive(:library_names).and_return(["missing_dawn.so"])

    expect { described_class.resolve_library_path }.to raise_error(Dawn::LoadError)
  end
end
