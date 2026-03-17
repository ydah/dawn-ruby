# Dawn WebGPU Ruby

Dawn bindings for Ruby, built on top of [`wgpu-ruby`](https://github.com/ydah/wgpu-ruby).

`dawn-webgpu` does not re-implement the standard WebGPU Ruby API. Instead, it swaps the native backend from `wgpu-native` to Dawn and adds Dawn-specific extensions (toggles, extension enums/structs, proc-table helpers, and compatibility patches).

## Status

This project currently provides a practical Dawn integration layer with:

- Dawn library loader and backend swap (`require "dawn"`)
- Compatibility patches for `wgpu-ruby` behavior that assumes `wgpu-native`
- Dawn-specific enum/struct/function extensions
- Dawn toggle descriptor builder
- Dawn-oriented wrapper classes (`Dawn::Instance`, `Dawn::Adapter`, `Dawn::Backend`)

### Standard WebGPU API surface

The standard WebGPU object model (`Instance`, `Adapter`, `Device`, `Buffer`, `Texture`, pipelines, passes, etc.) is provided by `wgpu-ruby`.

### Dawn-specific layer

- `Dawn::Loader` for shared library resolution
- `Dawn::Compatibility.patch!` for `wgpu-native`-specific call paths
- `Dawn::STypeExt` / `Dawn::FeatureNameExt`
- `Dawn::Native::DawnTogglesDescriptor` and related structs
- `Dawn::Toggles` for runtime toggle chaining

## Requirements

- Ruby 3.2+
- Dawn shared library
  - macOS: `libdawn.dylib` or `libwebgpu_dawn.dylib`
  - Linux: `libdawn.so` or `libwebgpu_dawn.so`
  - Windows: `dawn.dll` or `webgpu_dawn.dll`

## Installation

Add this line to your application's Gemfile:

```ruby
gem "dawn-webgpu"
```

Then run:

```bash
bundle install
```

## Native Library Setup

`require "dawn"` activates `Dawn::Loader` first, then loads `wgpu` with `WGPU_LIB_PATH` redirected to Dawn.

Library resolution order:

1. `DAWN_LIBRARY_PATH`
2. `DAWN_LIBRARY_DIR` + known library names
3. `~/.cache/dawn-ruby/<version>/lib`
4. `/usr/local/lib`, `/usr/lib`
5. `ext/dawn/lib` in current project

### Option A: Use an existing local Dawn build

```bash
export DAWN_LIBRARY_PATH=/absolute/path/to/libdawn.so
```

(Use `.dylib` on macOS or `.dll` on Windows.)

### Option B: Use extconf helper download path

`ext/dawn/extconf.rb` supports `DAWN_PREBUILT_URL` and caches to:

```text
~/.cache/dawn-ruby/<DAWN_VERSION>/lib
```

Example:

```bash
export DAWN_VERSION=v0.0.0
export DAWN_PREBUILT_URL=https://example.com/dawn-prebuilt.tar
bundle exec ruby ext/dawn/extconf.rb
```

## Quick Start

```ruby
require "dawn"

toggles = Dawn::Toggles.new.enable(:skip_validation)
instance = Dawn::Instance.new(toggles: toggles)
adapter = instance.request_adapter
device = adapter.request_device

puts adapter.summary

device.release
adapter.release
instance.release
```

## Toggle Example

```ruby
require "dawn"

toggles = Dawn::Toggles.new
  .enable(:skip_validation, :use_user_defined_labels_in_backend)
  .disable(:turn_off_vsync)

instance = Dawn::Instance.new(toggles: toggles)
# ...
instance.release
```

## API Coverage

| Area | Status | Notes |
| --- | --- | --- |
| Standard WebGPU Ruby API | Delegated | Provided by `wgpu-ruby` |
| Dawn backend swap (`WGPU_LIB_PATH`) | Implemented | Activated by `require "dawn"` |
| `wgpu-native` compatibility patches | Implemented | `wgpuDevicePoll`, `wgpuInstanceEnumerateAdapters` paths |
| Dawn extension enums (`SType`, `FeatureName`) | Implemented | `Dawn::STypeExt`, `Dawn::FeatureNameExt` |
| Dawn chained extension structs | Implemented | Toggle/internal usage/SPIR-V options/base host-mapped pointer structs |
| Dawn proc helpers | Implemented | `Dawn::Native.get_procs`, `Dawn::Native.set_procs!` |
| Integration tests with real Dawn runtime | Implemented | Compute and offscreen triangle specs run when Dawn is available and skip otherwise |

## Examples

```bash
ruby examples/dawn_info.rb
ruby examples/compute_shader.rb
ruby examples/hello_triangle.rb

# 2D offscreen rendering (writes PPM files to examples/output/)
ruby examples/render_triangle_2d.rb
ruby examples/render_blended_quads_2d.rb
ruby examples/render_circle_sdf_2d.rb

# 3D offscreen rendering (writes PPM files to examples/output/)
ruby examples/render_cube_3d.rb
ruby examples/render_pyramid_3d.rb
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rake build
```

## License

This project is available under the MIT License.

## Contributing

Bug reports and pull requests are welcome at:

- https://github.com/ydah/dawn-webgpu
