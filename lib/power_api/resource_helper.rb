module PowerApi
  module ResourceHelper
    def resource_name
      raise "Not implemented"
    end

    def validate_resource_name!(resources)
      fail "missing resource name" if resources.blank?

      if !resource_is_active_record_model?(resources)
        fail "resource is not an active record model"
      end

      true
    end

    def resource_is_active_record_model?(resource)
      klass = resource.classify.constantize
      !!ActiveRecord::Base.descendants.find { |model_class| model_class == klass }
    rescue NameError
      false
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
