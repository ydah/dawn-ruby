#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open-uri"
require_relative "../lib/dawn/native/enums_ext"

WEBGPU_HEADER_URL = ENV.fetch(
  "WEBGPU_HEADER_URL",
  "https://raw.githubusercontent.com/webgpu-native/webgpu-headers/main/webgpu.h"
)
DAWN_JSON_URL = ENV.fetch(
  "DAWN_JSON_URL",
  "https://raw.githubusercontent.com/google/dawn/main/src/dawn/dawn.json"
)
DAWN_FEATURE_OFFSET = 0x00050000
IGNORED_ALIASES = %i[FRAME_BUFFER_FETCH NORM16_TEXTURE_FORMATS].freeze

def fetch_text(url)
  URI.open(url, &:read)
end

def normalize_header_name(name)
  normalized = name
    .gsub("BCSliced3D", "BC_Sliced3D")
    .gsub("ASTCSliced3D", "ASTC_Sliced3D")
    .gsub("RG11B10Ufloat", "RG11B10_Ufloat")
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .downcase

  normalized
    .gsub("sliced3_d", "sliced_3d")
    .gsub("rg11_b10", "rg11b10")
    .to_sym
end

def normalize_json_name(name)
  name.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "").to_sym
end

def parse_standard_features(header)
  enum_body = header[/typedef enum WGPUFeatureName\s*\{(?<body>.*?)\}\s*WGPUFeatureName\b.*?;/m, :body]
  raise "WGPUFeatureName enum not found in #{WEBGPU_HEADER_URL}" unless enum_body

  enum_body.scan(/WGPUFeatureName_([A-Za-z0-9_]+)\s*=\s*(0x[0-9A-Fa-f]+)/).each_with_object({}) do |(name, value), map|
    normalized = normalize_header_name(name)
    next if normalized == :force32

    map[normalized] = Integer(value)
  end
end

def parse_dawn_extension_features(json)
  data = JSON.parse(json)
  values = data.fetch("feature name").fetch("values")

  values.each_with_object({}) do |entry, map|
    next unless Array(entry["tags"]).include?("dawn")

    map[normalize_json_name(entry.fetch("name"))] = DAWN_FEATURE_OFFSET + entry.fetch("value")
  end
end

def local_dawn_extension_features
  Dawn::FeatureNameExt.constants(false).sort.each_with_object({}) do |constant_name, map|
    next if constant_name == :STANDARD || IGNORED_ALIASES.include?(constant_name)

    value = Dawn::FeatureNameExt.const_get(constant_name)
    next unless value.is_a?(Integer) && value >= DAWN_FEATURE_OFFSET

    map[Dawn::FeatureNameExt.symbol_for(value)] = value
  end
end

def assert_equal_mappings!(label, actual, expected)
  return if actual == expected

  missing = expected.keys - actual.keys
  extra = actual.keys - expected.keys
  mismatched = expected.keys.intersection(actual.keys).filter_map do |key|
    next if actual[key] == expected[key]

    [key, actual[key], expected[key]]
  end

  message = []
  message << "#{label} drift detected."
  message << "Missing: #{missing.sort.join(', ')}" unless missing.empty?
  message << "Extra: #{extra.sort.join(', ')}" unless extra.empty?
  mismatched.each do |key, actual_value, expected_value|
    message << "Mismatch for #{key}: local=#{format('0x%08X', actual_value)} upstream=#{format('0x%08X', expected_value)}"
  end
  abort message.join("\n")
end

standard_features = parse_standard_features(fetch_text(WEBGPU_HEADER_URL))
dawn_extension_features = parse_dawn_extension_features(fetch_text(DAWN_JSON_URL))

assert_equal_mappings!("Standard WebGPU feature mapping", Dawn::FeatureNameExt::STANDARD, standard_features)
assert_equal_mappings!("Dawn extension feature mapping", local_dawn_extension_features, dawn_extension_features)

puts "Verified #{standard_features.size} standard WebGPU features against #{WEBGPU_HEADER_URL}"
puts "Verified #{dawn_extension_features.size} Dawn extension features against #{DAWN_JSON_URL}"
