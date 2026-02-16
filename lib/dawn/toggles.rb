# frozen_string_literal: true

module Dawn
  class Toggles
    KNOWN = {
      :emulate_store_and_msaa_resolve => "emulate_store_and_msaa_resolve",
      :nonzero_clear_resources_on_creation_for_testing => "nonzero_clear_resources_on_creation_for_testing",
      :always_resolve_into_zero_level_and_layer => "always_resolve_into_zero_level_and_layer",
      :lazy_clear_resource_on_first_use => "lazy_clear_resource_on_first_use",
      :disable_lazy_clear_for_mapped_at_creation_buffer => "disable_lazy_clear_for_mapped_at_creation_buffer",
      :turn_off_vsync => "turn_off_vsync",
      :use_temporary_buffer_in_texture_to_texture_copy => "use_temporary_buffer_in_texture_to_texture_copy",
      :use_d3d12_resource_heap_tier2 => "use_d3d12_resource_heap_tier2",
      :use_d3d12_render_pass => "use_d3d12_render_pass",
      :use_d3d12_residency_management => "use_d3d12_residency_management",
      :disable_resource_suballocation => "disable_resource_suballocation",
      :skip_validation => "skip_validation",
      :vulkan_use_d32s8 => "vulkan_use_d32s8",
      :vulkan_use_s8 => "vulkan_use_s8",
      :metal_disable_sampler_compare => "metal_disable_sampler_compare",
      :metal_use_shared_mode_for_counter_sample_buffer => "metal_use_shared_mode_for_counter_sample_buffer",
      :disable_base_vertex => "disable_base_vertex",
      :disable_base_instance => "disable_base_instance",
      :disable_indexed_draw_buffers => "disable_indexed_draw_buffers",
      :disable_sample_variables => "disable_sample_variables",
      :disable_bind_group_layout_entry_array_size => "disable_bind_group_layout_entry_array_size",
      :use_d3d12_small_shader_visible_heap => "use_d3d12_small_shader_visible_heap",
      :use_dxc => "use_dxc",
      :disable_robustness => "disable_robustness",
      :metal_enable_vertex_pulling => "metal_enable_vertex_pulling",
      :allow_unsafe_apis => "allow_unsafe_apis",
      :flush_before_client_wait_sync => "flush_before_client_wait_sync",
      :use_temp_buffer_in_small_format_texture_to_texture_copy_from_greater_to_less_mip_level => "use_temp_buffer_in_small_format_texture_to_texture_copy_from_greater_to_less_mip_level",
      :emit_hlsl_debug_symbols => "emit_hlsl_debug_symbols",
      :disallow_spirv => "disallow_spirv",
      :dump_shaders => "dump_shaders",
      :dump_shaders_on_failure => "dump_shaders_on_failure",
      :disable_workgroup_init => "disable_workgroup_init",
      :disable_demote_to_helper => "disable_demote_to_helper",
      :vulkan_use_demote_to_helper_invocation_extension => "vulkan_use_demote_to_helper_invocation_extension",
      :disable_symbol_renaming => "disable_symbol_renaming",
      :use_user_defined_labels_in_backend => "use_user_defined_labels_in_backend",
      :use_placeholder_fragment_in_vertex_only_pipeline => "use_placeholder_fragment_in_vertex_only_pipeline",
      :fxc_optimizations => "fxc_optimizations",
      :record_detailed_timing_in_trace_events => "record_detailed_timing_in_trace_events",
      :disable_timestamp_query_conversion => "disable_timestamp_query_conversion",
      :timestamp_quantization => "timestamp_quantization",
      :clear_buffer_before_resolve_queries => "clear_buffer_before_resolve_queries",
      :use_vulkan_zero_initialize_workgroup_memory_extension => "use_vulkan_zero_initialize_workgroup_memory_extension",
      :metal_render_r8_rg8_unorm_small_mip_to_temp_texture => "metal_render_r8_rg8_unorm_small_mip_to_temp_texture",
      :disable_blob_cache => "disable_blob_cache",
      :d3d12_force_clear_copyable_depth_stencil_texture_on_creation => "d3d12_force_clear_copyable_depth_stencil_texture_on_creation",
      :d3d12_dont_set_clear_value_on_depth_texture_creation => "d3d12_dont_set_clear_value_on_depth_texture_creation",
      :d3d12_always_use_typeless_formats_for_castable_texture => "d3d12_always_use_typeless_formats_for_castable_texture",
      :d3d12_allocate_extra_memory_for_2d_array_color_texture => "d3d12_allocate_extra_memory_for_2d_array_color_texture",
      :d3d12_use_temp_buffer_in_depth_stencil_texture_and_buffer_copy_with_non_zero_buffer_offset => "d3d12_use_temp_buffer_in_depth_stencil_texture_and_buffer_copy_with_non_zero_buffer_offset",
      :d3d12_use_temp_buffer_in_texture_to_texture_copy_between_different_dimensions => "d3d12_use_temp_buffer_in_texture_to_texture_copy_between_different_dimensions",
      :apply_clear_big_integer_color_value_with_draw => "apply_clear_big_integer_color_value_with_draw",
      :metal_use_mock_blit_encoder_for_write_timestamp => "metal_use_mock_blit_encoder_for_write_timestamp",
      :metal_disable_timestamp_period_estimation => "metal_disable_timestamp_period_estimation",
      :vulkan_split_command_buffer_on_compute_pass_after_render_pass => "vulkan_split_command_buffer_on_compute_pass_after_render_pass",
      :disable_sub_allocation_for_2d_texture_with_copy_dst_or_render_attachment => "disable_sub_allocation_for_2d_texture_with_copy_dst_or_render_attachment",
      :metal_use_combined_depth_stencil_format_for_stencil8 => "metal_use_combined_depth_stencil_format_for_stencil8",
      :metal_use_both_depth_and_stencil_attachments_for_combined_depth_stencil_formats => "metal_use_both_depth_and_stencil_attachments_for_combined_depth_stencil_formats",
      :metal_keep_multisubresource_depth_stencil_textures_initialized => "metal_keep_multisubresource_depth_stencil_textures_initialized",
      :metal_polyfill_unpack_2x16_snorm => "metal_polyfill_unpack_2x16_snorm",
      :metal_polyfill_unpack_2x16_unorm => "metal_polyfill_unpack_2x16_unorm",
      :metal_polyfill_tanh_f16 => "metal_polyfill_tanh_f16",
      :spirv_polyfill_f32_negation => "spirv_polyfill_f32_negation",
      :spirv_polyfill_f32_abs => "spirv_polyfill_f32_abs",
      :metal_fill_empty_occlusion_queries_with_zero => "metal_fill_empty_occlusion_queries_with_zero",
      :use_blit_for_buffer_to_depth_texture_copy => "use_blit_for_buffer_to_depth_texture_copy",
      :use_blit_for_buffer_to_stencil_texture_copy => "use_blit_for_buffer_to_stencil_texture_copy",
      :use_blit_for_stencil_texture_write => "use_blit_for_stencil_texture_write",
      :use_blit_for_depth_texture_to_texture_copy_to_nonzero_subresource => "use_blit_for_depth_texture_to_texture_copy_to_nonzero_subresource",
      :use_blit_for_depth16unorm_texture_to_buffer_copy => "use_blit_for_depth16unorm_texture_to_buffer_copy",
      :use_blit_for_depth24plus_texture_to_buffer_copy => "use_blit_for_depth24plus_texture_to_buffer_copy",
      :use_blit_for_depth32float_texture_to_buffer_copy => "use_blit_for_depth32float_texture_to_buffer_copy",
      :use_blit_for_stencil_texture_to_buffer_copy => "use_blit_for_stencil_texture_to_buffer_copy",
      :use_blit_for_snorm_texture_to_buffer_copy => "use_blit_for_snorm_texture_to_buffer_copy",
      :use_blit_for_bgra8unorm_texture_to_buffer_copy => "use_blit_for_bgra8unorm_texture_to_buffer_copy",
      :use_blit_for_rgb9e5ufloat_texture_copy => "use_blit_for_rgb9e5ufloat_texture_copy",
      :use_blit_for_rg11b10ufloat_texture_copy => "use_blit_for_rg11b10ufloat_texture_copy",
      :use_blit_for_float_16_texture_copy => "use_blit_for_float_16_texture_copy",
      :use_blit_for_float_32_texture_copy => "use_blit_for_float_32_texture_copy",
      :use_blit_for_t2b => "use_blit_for_t2b",
      :use_blit_for_b2t => "use_blit_for_b2t",
      :gl_use_array_length_from_uniform => "gl_use_array_length_from_uniform",
      :d3d11_disable_cpu_buffers => "d3d11_disable_cpu_buffers",
      :use_t2b2t_for_srgb_texture_copy => "use_t2b2t_for_srgb_texture_copy",
      :d3d12_replace_add_with_minus_when_dst_factor_is_zero_and_src_factor_is_dst_alpha => "d3d12_replace_add_with_minus_when_dst_factor_is_zero_and_src_factor_is_dst_alpha",
      :d3d12_polyfill_reflect_vec2_f32 => "d3d12_polyfill_reflect_vec2_f32",
      :vulkan_clear_gen12_texture_with_ccs_ambiguate_on_creation => "vulkan_clear_gen12_texture_with_ccs_ambiguate_on_creation",
      :d3d12_use_root_signature_version_1_1 => "d3d12_use_root_signature_version_1_1",
      :vulkan_use_image_robust_access_2 => "vulkan_use_image_robust_access_2",
      :vulkan_use_buffer_robust_access_2 => "vulkan_use_buffer_robust_access_2",
      :d3d12_use_64kb_alignment_msaa_texture => "d3d12_use_64kb_alignment_msaa_texture",
      :resolve_multiple_attachments_in_separate_passes => "resolve_multiple_attachments_in_separate_passes",
      :d3d12_create_not_zeroed_heap => "d3d12_create_not_zeroed_heap",
      :d3d12_dont_use_not_zeroed_heap_flag_on_textures_as_commited_resources => "d3d12_dont_use_not_zeroed_heap_flag_on_textures_as_commited_resources",
      :d3d_disable_ieee_strictness => "d3d_disable_ieee_strictness",
      :d3d_skip_shader_optimizations => "d3d_skip_shader_optimizations",
      :polyfill_packed_4x8_dot_product => "polyfill_packed_4x8_dot_product",
      :polyfill_pack_unpack_4x8_norm => "polyfill_pack_unpack_4x8_norm",
      :enable_subgroups_intel_gen9 => "enable_subgroups_intel_gen9",
      :d3d12_polyfill_pack_unpack_4x8 => "d3d12_polyfill_pack_unpack_4x8",
      :vulkan_polyfill_switch_with_if => "vulkan_polyfill_switch_with_if",
      :expose_wgsl_testing_features => "expose_wgsl_testing_features",
      :expose_wgsl_experimental_features => "expose_wgsl_experimental_features",
      :disable_polyfills_on_integer_div_and_mod => "disable_polyfills_on_integer_div_and_mod",
      :scalarize_max_min_clamp => "scalarize_max_min_clamp",
      :saturate_as_min_max_f16 => "saturate_as_min_max_f16",
      :metal_polyfill_clamp_float => "metal_polyfill_clamp_float",
      :subgroup_shuffle_clamped => "subgroup_shuffle_clamped",
      :vulkan_sample_compare_depth_cube_array_workaround => "vulkan_sample_compare_depth_cube_array_workaround",
      :metal_disable_module_constant_f16 => "metal_disable_module_constant_f16",
      :enable_immediate_error_handling => "enable_immediate_error_handling",
      :vulkan_use_storage_input_output_16 => "vulkan_use_storage_input_output_16",
      :d3d12_dont_use_shader_model_66_or_higher => "d3d12_dont_use_shader_model_66_or_higher",
      :use_packed_depth24_unorm_stencil8_format => "use_packed_depth24_unorm_stencil8_format",
      :d3d12_force_stencil_component_replicate_swizzle => "d3d12_force_stencil_component_replicate_swizzle",
      :d3d12_expand_shader_resource_state_transitions_to_copy_source => "d3d12_expand_shader_resource_state_transitions_to_copy_source",
      :gl_depth_bias_modifier => "gl_depth_bias_modifier",
      :gl_force_es_31_and_no_extensions => "gl_force_es_31_and_no_extensions",
      :vulkan_monolithic_pipeline_cache => "vulkan_monolithic_pipeline_cache",
      :vulkan_incomplete_pipeline_cache_workaround => "vulkan_incomplete_pipeline_cache_workaround",
      :metal_serialize_timestamp_generation_and_resolution => "metal_serialize_timestamp_generation_and_resolution",
      :d3d12_relax_min_subgroup_size_to_8 => "d3d12_relax_min_subgroup_size_to_8",
      :d3d12_relax_buffer_texture_copy_pitch_and_offset_alignment => "d3d12_relax_buffer_texture_copy_pitch_and_offset_alignment",
      :use_vulkan_memory_model => "use_vulkan_memory_model",
      :vulkan_direct_variable_access_transform_handle => "vulkan_direct_variable_access_transform_handle",
      :vulkan_add_work_to_empty_resolve_pass => "vulkan_add_work_to_empty_resolve_pass",
      :enable_integer_range_analysis_in_robustness => "enable_integer_range_analysis_in_robustness",
      :use_spirv_1_4 => "use_spirv_1_4",
      :metal_use_argument_buffers => "metal_use_argument_buffers",
      :enable_shader_print => "enable_shader_print",
      :blob_cache_hash_validation => "blob_cache_hash_validation",
      :decompose_uniform_buffers => "decompose_uniform_buffers",
      :vulkan_enable_f16_on_nvidia => "vulkan_enable_f16_on_nvidia",
      :enable_renderdoc_process_injection => "enable_renderdoc_process_injection",
      :vulkan_use_dynamic_rendering => "vulkan_use_dynamic_rendering",
      :enable_spirv_validation => "enable_spirv_validation",
      :vulkan_use_create_render_pass_2 => "vulkan_use_create_render_pass_2",
      :wait_is_thread_safe => "wait_is_thread_safe",
      :no_workaround_sample_mask_becomes_zero_for_all_but_last_color_target => "no_workaround_sample_mask_becomes_zero_for_all_but_last_color_target",
      :no_workaround_indirect_base_vertex_not_applied => "no_workaround_indirect_base_vertex_not_applied",
      :no_workaround_dst_alpha_as_src_blend_factor_for_both_color_and_alpha_does_not_work => "no_workaround_dst_alpha_as_src_blend_factor_for_both_color_and_alpha_does_not_work",
      :clear_color_with_draw => "clear_color_with_draw",
      :vulkan_skip_draw => "vulkan_skip_draw",
      :d3d11_use_unmonitored_fence => "d3d11_use_unmonitored_fence",
      :d3d11_disable_fence => "d3d11_disable_fence",
      :d3d11_delay_flush_to_gpu => "d3d11_delay_flush_to_gpu",
      :ignore_imported_ahardwarebuffer_vulkan_image_size => "ignore_imported_ahardwarebuffer_vulkan_image_size",
      :gl_allow_context_on_multi_threads => "gl_allow_context_on_multi_threads",
      :gl_defer => "gl_defer",
      :disable_transient_attachment => "disable_transient_attachment",
      :auto_map_backend_buffer => "auto_map_backend_buffer"
    }.freeze

    attr_reader :enabled, :disabled

    def initialize
      @enabled = []
      @disabled = []
      @allocations = []
    end

    def enable(*toggles)
      toggles.each { |toggle| @enabled << resolve(toggle) }
      self
    end

    def disable(*toggles)
      toggles.each { |toggle| @disabled << resolve(toggle) }
      self
    end

    def to_descriptor
      enabled_ptrs = @enabled.map { |name| FFI::MemoryPointer.from_string(name) }
      disabled_ptrs = @disabled.map { |name| FFI::MemoryPointer.from_string(name) }

      enabled_array = build_pointer_array(enabled_ptrs)
      disabled_array = build_pointer_array(disabled_ptrs)

      descriptor = Dawn::Native::DawnTogglesDescriptor.new
      descriptor[:chain][:next] = nil
      descriptor[:chain][:s_type] = Dawn::STypeExt::DAWN_TOGGLES_DESCRIPTOR
      descriptor[:enabled_toggle_count] = enabled_ptrs.size
      descriptor[:enabled_toggles] = enabled_array || FFI::Pointer::NULL
      descriptor[:disabled_toggle_count] = disabled_ptrs.size
      descriptor[:disabled_toggles] = disabled_array || FFI::Pointer::NULL

      @allocations = [descriptor, enabled_array, disabled_array, *enabled_ptrs, *disabled_ptrs]
      descriptor
    end

    private

    def build_pointer_array(strings)
      return nil if strings.empty?

      ptr = FFI::MemoryPointer.new(:pointer, strings.size)
      ptr.write_array_of_pointer(strings)
      ptr
    end

    def resolve(toggle)
      return toggle if toggle.is_a?(String)

      KNOWN.fetch(toggle) { raise ArgumentError, "Unknown toggle: #{toggle}" }
    end
  end
end
