# frozen_string_literal: true

require "rbconfig"

module Dawn
  module Backend
    VULKAN = :vulkan
    METAL = :metal
    D3D12 = :d3d12
    D3D11 = :d3d11
    OPENGL = :opengl
    OPENGLES = :opengles
    NULL = :null

    module_function

    def preferred
      case RbConfig::CONFIG["host_os"]
      when /darwin/
        METAL
      when /linux/
        VULKAN
      when /mingw|mswin/
        D3D12
      else
        NULL
      end
    end
  end
end
