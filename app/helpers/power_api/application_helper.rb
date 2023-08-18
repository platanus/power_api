module PowerApi
  module ApplicationHelper
    VALID_SERIALIZER_OUTPUT_FORMATS = %i{json hash}

    def serialize_resource(resource, options = {})
      load_default_serializer_options(options)
      serialized_data = serialize_data(resource, options)
      render_serialized_data(serialized_data, options)
    rescue NoMethodError => e
      if e.message.include?("undefined method `serializable_hash'")
        raise ::PowerApi::InvalidSerializableResource.new(
          "Invalid #{resource.class} resource given. Must be ActiveRecord instance or collection"
        )
      else
        raise e
      end
    end

    private

    def serialize_data(resource, options)
      return {} if resource.nil?

      serializable = ActiveModelSerializers::SerializableResource.new(resource, options)
      serializable.serializable_hash
    end

    def render_serialized_data(serialized_data, options)
      output_format = options.delete(:output_format)
      serialized_data = serialized_data.fetch(:root, serialized_data)
      return serialized_data if output_format == :hash

      serialized_data.presence.to_json
    end

    def load_default_serializer_options(options)
      options[:namespace] ||= "Api::Internal"
      options[:key_transform] ||= :camel_lower
      options[:include_root] ||= false
      options[:output_format] = format_serializer_output_format!(options[:output_format])
      options[:key_transform] = :unaltered if options[:output_format] == :hash

      load_root_option(options)
      options
    end

    def load_root_option(options)
      return if !!options.delete(:include_root)

      options[:root] = :root
    end

    def format_serializer_output_format!(output_format)
      return :json if output_format.blank?

      output_format = output_format.to_s.to_sym

      if !VALID_SERIALIZER_OUTPUT_FORMATS.include?(output_format)
        raise ::PowerApi::InvalidSerializerOutputFormat.new(
          "Only #{VALID_SERIALIZER_OUTPUT_FORMATS} values are allowed."
        )
      end

      output_format
    end
  end
end
