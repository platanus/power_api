module PowerApi
  module ResourceHelper
    def resource_name
      @resource_name
    end

    def resource_name=(value)
      @resource_name = value

      raise GeneratorError.new("missing resource name") if resource_name.blank?

      if !resource_is_active_record_model?
        raise GeneratorError.new("resource is not an active record model")
      end
    end

    def validate_resource_name!(resource)
      raise GeneratorError.new("missing resource name") if resource.blank?

      if !resource_is_active_record_model?(resource)
        raise GeneratorError.new("resource is not an active record model")
      end

      true
    end

    def resource_is_active_record_model?
      !!ActiveRecord::Base.descendants.find { |model_class| model_class == resource_class }
    rescue NameError
      false
    end

    def resource_class
      resource_name.classify.constantize
    end

    def camel_resource
      resource_name.camelize
    end

    def plural_resource
      resource_name.pluralize
    end

    def snake_case_resource
      resource_name.underscore
    end
  end
end
