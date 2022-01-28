module PowerApi
  module ApplicationHelper
    VALID_SERIALIZER_OUTPUTS = %i{json hash}

    def serialize_resource(resource, options = {})
      load_default_serializer_options(options)
      serializable = ActiveModelSerializers::SerializableResource.new(resource, options)
      serialized_data = serializable.serializable_hash
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

    def render_serialized_data(serialized_data, options)
      output = options.delete(:output)
      serialized_data = serialized_data[:root] if options[:root] == :root
      return serialized_data if output == :hash

      serialized_data.to_json
    end

    def load_default_serializer_options(options)
      options[:namespace] ||= "Api::Internal"
      options[:key_transform] ||= :camel_lower
      options[:include_root] ||= false
      options[:output] = format_serializer_output!(options[:output])
      options[:key_transform] = :unaltered if options[:output] == :hash

      load_root_option(options)
      options
    end

    def load_root_option(options)
      return if !!options.delete(:include_root)

      options[:root] = :root
    end

    def format_serializer_output!(output)
      return :json if output.blank?

      output = output.to_s.to_sym

      if !VALID_SERIALIZER_OUTPUTS.include?(output)
        raise ::PowerApi::InvalidSerializerOutput.new(
          "Only #{VALID_SERIALIZER_OUTPUTS} values are allowed."
        )
      end

      output
    end
  end
end
