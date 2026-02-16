# frozen_string_literal: true

require "dawn"

instance = Dawn::Instance.new
adapter = instance.request_adapter

puts "Dawn adapter: #{adapter.summary}"
puts "Backend: #{adapter.backend}"
puts "Features: #{adapter.features.sort.join(", ")}"

instance.release
