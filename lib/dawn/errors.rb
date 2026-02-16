# frozen_string_literal: true

module Dawn
  class Error < StandardError; end
  class LoadError < Error; end
  class CompatibilityError < Error; end
end
