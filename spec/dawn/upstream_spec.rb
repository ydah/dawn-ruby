# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../lib/dawn/upstream"

RSpec.describe Dawn::Upstream do
  around do |example|
    original = ENV.to_h
    begin
      example.run
    ensure
      ENV.replace(original)
    end
  end

  it "uses the upstream Dawn version for the cache directory" do
    ENV["DAWN_VERSION"] = "9999"

    expect(described_class.cache_dir).to end_with("/.cache/dawn-ruby/9999")
    expect(described_class.library_dir).to end_with("/.cache/dawn-ruby/9999/lib")
  end

  it "builds the default prebuilt archive URL for macOS arm64" do
    expect(
      described_class.prebuilt_url(host_os: "darwin23.6.0", host_cpu: "arm64", version: "7187", mirror: "https://example.test")
    ).to eq(
      "https://example.test/releases/download/chromium/7187/Dawn-7187-macos-aarch64-Release.zip"
    )
  end

  it "honors an explicit prebuilt URL override" do
    ENV["DAWN_PREBUILT_URL"] = "https://downloads.example.test/custom-dawn.zip"

    expect(described_class.prebuilt_url(host_os: "linux", host_cpu: "x86_64")).to eq(
      "https://downloads.example.test/custom-dawn.zip"
    )
  end

  it "reports unsupported default prebuilt targets" do
    expect(described_class.prebuilt_supported?(host_os: "linux", host_cpu: "aarch64")).to be(false)
    expect { described_class.prebuilt_archive_name(host_os: "linux", host_cpu: "aarch64") }.to raise_error(Dawn::LoadError)
  end
end
