# frozen_string_literal: true

module Dawn
  module Compatibility
    class << self
      def patch!
        patch_instance_from_handle!
        patch_adapter_instance_tracking!
        patch_enumerate_adapters!
        patch_feature_names!
        patch_device_poll!
        patch_queue_wait!
        patch_buffer_wait!
        patch_shader_module_wait!
      end

      def symbol_available?(name)
        symbol_name = name.to_sym

        # Dawn may define stub singleton methods for optional symbols when they
        # are missing from the native backend. Use FFI's attached function table
        # first so stubs are not treated as available symbols.
        attached = WGPU::Native.respond_to?(:attached_functions) &&
                   WGPU::Native.attached_functions.key?(symbol_name)
        return true if attached

        return false unless WGPU::Native.respond_to?(:ffi_libraries)

        WGPU::Native.ffi_libraries.any? do |library|
          library.respond_to?(:find_symbol) && !library.find_symbol(symbol_name.to_s).nil?
        end
      rescue FFI::NotFoundError, NoMethodError
        false
      end

      def poll_device(device, wait: false)
        if symbol_available?(:wgpuDevicePoll)
          WGPU::Native.wgpuDevicePoll(device.handle, wait ? 1 : 0, nil)
          return
        end

        process_events_for_device(device)
      end

      def feature_names_from(supported)
        return [] if supported[:feature_count].zero? || supported[:features].null?

        supported[:features].read_array_of_uint32(supported[:feature_count]).map do |value|
          Dawn::FeatureNameExt.symbol_for(value)
        end
      end

      def normalize_feature_name(feature)
        return feature if feature.is_a?(Symbol)

        Dawn::FeatureNameExt.symbol_for(normalize_feature_value(feature))
      end

      def normalize_feature_value(feature)
        Dawn::FeatureNameExt.value_for(feature)
      end

      def process_events_for_device(device)
        instance_handle = device&.adapter&.instance_handle
        return if instance_handle.nil? || instance_handle.null?

        WGPU::Native.wgpuInstanceProcessEvents(instance_handle)
      end

      private

      def patch_instance_from_handle!
        singleton = WGPU::Instance.singleton_class
        return if singleton.method_defined?(:from_handle)

        singleton.class_eval do
          def from_handle(handle)
            instance = allocate
            instance.instance_variable_set(:@handle, handle)
            instance
          end
        end
      end

      def patch_adapter_instance_tracking!
        WGPU::Adapter.class_eval do
          attr_reader :instance_handle
        end

        singleton = WGPU::Adapter.singleton_class

        unless singleton.method_defined?(:__dawn_request_without_instance_tracking)
          singleton.alias_method :__dawn_request_without_instance_tracking, :request
          singleton.define_method(:request) do |instance, **options|
            adapter = __dawn_request_without_instance_tracking(instance, **options)
            adapter.instance_variable_set(:@instance_handle, instance.handle)
            adapter
          end
        end

        unless singleton.method_defined?(:__dawn_from_handle_without_instance_tracking)
          singleton.alias_method :__dawn_from_handle_without_instance_tracking, :from_handle
          singleton.define_method(:from_handle) do |handle, instance_handle: nil|
            adapter = __dawn_from_handle_without_instance_tracking(handle)
            adapter.instance_variable_set(:@instance_handle, instance_handle)
            adapter
          end
        end
      end

      def patch_enumerate_adapters!
        return if WGPU::Instance.method_defined?(:__dawn_enumerate_adapters_without_patch)

        WGPU::Instance.class_eval do
          alias_method :__dawn_enumerate_adapters_without_patch, :enumerate_adapters

          def enumerate_adapters(backends: nil)
            if Dawn::Compatibility.symbol_available?(:wgpuInstanceEnumerateAdapters)
              adapters = __dawn_enumerate_adapters_without_patch(backends: backends)
              adapters.each { |adapter| adapter.instance_variable_set(:@instance_handle, @handle) }
              return adapters
            end

            adapter = request_adapter
            adapter ? [adapter] : []
          rescue WGPU::AdapterError
            []
          end

          def enumerate_adapters_async(backends: nil)
            AsyncTask.new do
              enumerate_adapters(backends: backends)
            end
          end
        end
      end

      def patch_feature_names!
        patch_adapter_feature_names!
        patch_device_feature_names!
        patch_device_feature_normalization!
      end

      def patch_adapter_feature_names!
        return if WGPU::Adapter.method_defined?(:__dawn_features_without_patch)

        WGPU::Adapter.class_eval do
          alias_method :__dawn_features_without_patch, :features
          alias_method :__dawn_has_feature_without_patch, :has_feature?

          def features
            supported = WGPU::Native::SupportedFeatures.new
            WGPU::Native.wgpuAdapterGetFeatures(@handle, supported)
            Dawn::Compatibility.feature_names_from(supported)
          end

          def has_feature?(feature)
            features.include?(Dawn::Compatibility.normalize_feature_name(feature))
          end
        end
      end

      def patch_device_feature_names!
        return if WGPU::Device.method_defined?(:__dawn_features_without_patch)

        WGPU::Device.class_eval do
          alias_method :__dawn_features_without_patch, :features
          alias_method :__dawn_has_feature_without_patch, :has_feature?

          def features
            supported = WGPU::Native::SupportedFeatures.new
            WGPU::Native.wgpuDeviceGetFeatures(@handle, supported)
            Dawn::Compatibility.feature_names_from(supported)
          end

          def has_feature?(feature)
            features.include?(Dawn::Compatibility.normalize_feature_name(feature))
          end
        end
      end

      def patch_device_feature_normalization!
        singleton = WGPU::Device.singleton_class
        return if singleton.private_method_defined?(:__dawn_normalize_feature_name_without_patch)

        singleton.alias_method :__dawn_normalize_feature_name_without_patch, :normalize_feature_name
        singleton.define_method(:normalize_feature_name) do |feature|
          Dawn::Compatibility.normalize_feature_value(feature)
        end
        singleton.send(:private, :normalize_feature_name, :__dawn_normalize_feature_name_without_patch)
      end

      def patch_device_poll!
        return if WGPU::Device.method_defined?(:__dawn_poll_without_patch)

        WGPU::Device.class_eval do
          alias_method :__dawn_poll_without_patch, :poll

          def poll(wait: false)
            Dawn::Compatibility.poll_device(self, wait: wait)
          end
        end
      end

      def patch_queue_wait!
        mod = Module.new do
          def on_submitted_work_done(device: nil)
            device ||= @device
            status_holder = { done: false, status: nil }

            callback = FFI::Function.new(
              :void, [:uint32, :pointer, :pointer]
            ) do |status, _userdata1, _userdata2|
              status_holder[:done] = true
              status_holder[:status] = Native::QueueWorkDoneStatus[status]
            end

            callback_info = Native::QueueWorkDoneCallbackInfo.new
            callback_info[:next_in_chain] = nil
            callback_info[:mode] = 1
            callback_info[:callback] = callback
            callback_info[:userdata1] = nil
            callback_info[:userdata2] = nil

            Native.wgpuQueueOnSubmittedWorkDone(@handle, callback_info)

            if device
              until status_holder[:done]
                Dawn::Compatibility.poll_device(device, wait: false)
                sleep(0.001)
              end
            else
              sleep(0.001) until status_holder[:done]
            end

            status_holder[:status]
          end
        end

        WGPU::Queue.prepend(mod)
      end

      def patch_buffer_wait!
        mod = Module.new do
          private

          def wait_for_map(status_holder, _future = nil)
            until status_holder[:done]
              Dawn::Compatibility.poll_device(@device, wait: false)
              sleep(0.001)
            end
          end
        end

        WGPU::Buffer.prepend(mod)
      end

      def patch_shader_module_wait!
        mod = Module.new do
          def get_compilation_info
            result_holder = { done: false, status: nil, messages: [] }

            callback = FFI::Function.new(
              :void, [:uint32, :pointer, :pointer, :pointer]
            ) do |status, compilation_info_ptr, _userdata1, _userdata2|
              result_holder[:done] = true
              result_holder[:status] = Native::CompilationInfoRequestStatus[status]

              unless compilation_info_ptr.null?
                info = Native::CompilationInfo.new(compilation_info_ptr)
                count = info[:message_count]
                if count > 0 && !info[:messages].null?
                  count.times do |i|
                    msg_ptr = info[:messages] + (i * Native::CompilationMessage.size)
                    msg = Native::CompilationMessage.new(msg_ptr)
                    message_text = if msg[:message][:data] && !msg[:message][:data].null? && msg[:message][:length] > 0
                                     msg[:message][:data].read_string(msg[:message][:length])
                                   else
                                     ""
                                   end
                    result_holder[:messages] << {
                      type: msg[:type],
                      message: message_text,
                      line_num: msg[:line_num],
                      line_pos: msg[:line_pos],
                      offset: msg[:offset],
                      length: msg[:length]
                    }
                  end
                end
              end
            end

            callback_info = Native::CompilationInfoCallbackInfo.new
            callback_info[:next_in_chain] = nil
            callback_info[:mode] = 1
            callback_info[:callback] = callback
            callback_info[:userdata1] = nil
            callback_info[:userdata2] = nil

            Native.wgpuShaderModuleGetCompilationInfo(@handle, callback_info)

            until result_holder[:done]
              Dawn::Compatibility.poll_device(@device, wait: false)
              sleep(0.001)
            end

            {
              status: result_holder[:status],
              messages: result_holder[:messages]
            }
          end
        end

        WGPU::ShaderModule.prepend(mod)
      end
    end
  end
end
