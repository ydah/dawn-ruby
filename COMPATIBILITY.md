# Dawn vs wgpu-native Compatibility

`wgpu-ruby` targets `wgpu-native` directly. `dawn-webgpu` keeps the Ruby API but swaps the native runtime to Dawn.

## Incompatible symbols in `wgpu-ruby` high-level code

- `wgpuDevicePoll`
- `wgpuInstanceEnumerateAdapters`

## Patched call sites

- `WGPU::Device#poll`
- `WGPU::Queue#on_submitted_work_done`
- `WGPU::Buffer#wait_for_map`
- `WGPU::ShaderModule#get_compilation_info`
- `WGPU::Instance#enumerate_adapters`

## Behavior notes

- If `wgpuDevicePoll` is unavailable, polling falls back to `wgpuInstanceProcessEvents` using tracked adapter instance handles.
- If `wgpuInstanceEnumerateAdapters` is unavailable, adapter enumeration falls back to `request_adapter` and returns zero or one adapter.
- Dawn-specific enum extensions are exposed as integer constants; they are not merged into `WGPU::Native` FFI enums.
