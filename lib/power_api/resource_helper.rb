module PowerApi
  module ResourceHelper
    extend ActiveSupport::Concern

    included do
      attr_reader :resource_name, :resource_attributes

      def resource_name=(value)
        @resource_name = value

        if !resource_class
          raise GeneratorError.new(
            "Invalid resource name. Must be the snake_case representation of a ruby class"
          )
        end

        if !resource_is_active_record_model?
          raise GeneratorError.new("resource is not an active record model")
        end
      end

      def resource_attributes=(collection)
        attributes = format_attributes(collection)
        raise GeneratorError.new("at least one attribute must be added") if attributes.none?

        @resource_attributes = attributes
      end

      def resource_is_active_record_model?
        !!ActiveRecord::Base.descendants.find { |model_class| model_class == resource_class }
      end

      def resource_class
        resource_name.classify.constantize
      rescue NameError
        false
      end

      def camel_resource
        resource_name.camelize
      end

      def camel_plural_resource
        camel_resource.pluralize
      end

      def plural_resource
        resource_name.pluralize
      end

      def snake_case_resource
        resource_name.underscore
      end

      def resource_attributes_names
        resource_attributes.map { |attr| attr[:name] }
      end

      def resource_attributes_symbols_text_list
        resource_attributes_names.map { |a| ":#{a}" }.join(', ')
      end

      def format_attributes(attrs)
        columns = resource_class.columns.inject([]) do |memo, col|
          col_name = col.name.to_sym
          next memo if col_name == :id

          memo << { name: col_name, type: col.type }
          memo
        end

        return columns if attrs.blank?

        attrs = attrs.map(&:to_sym)
        columns.select { |col| attrs.include?(col[:name]) }
      end
    end
  end
end
