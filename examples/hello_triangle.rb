# frozen_string_literal: true

require "dawn"

instance = Dawn::Instance.new
adapter = instance.request_adapter
device = adapter.request_device

puts "Triangle sample scaffold initialized on #{adapter.summary}"

device.release
adapter.release
instance.release
