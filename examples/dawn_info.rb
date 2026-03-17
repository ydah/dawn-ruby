# frozen_string_literal: true

require "dawn"

instance = Dawn::Instance.new
adapter = instance.request_adapter
known_toggles = Dawn::Toggles::KNOWN.keys.map(&:to_s).sort

puts "Dawn adapter: #{adapter.summary}"
puts "Backend: #{adapter.backend}"
puts "Features: #{adapter.features.sort.join(", ")}"
puts "Known toggles: #{known_toggles.size}"
puts "Toggle sample: #{known_toggles.first(8).join(", ")}"

adapter.release
instance.release
