# frozen_string_literal: true

begin
  require "bundler/setup"
rescue StandardError
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
