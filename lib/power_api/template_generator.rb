module PowerApi
  class TemplateGenerator
    attr_reader :version_number, :resource_name

    def initialize(config)
      assign_version_number(config[:version_number])
      assign_resource_name(config[:resource_name])
    end

    def generate_controller_tpl

    end

    private

    def assign_version_number(version_number)
      version = version_number.to_s.to_i
      fail "invalid version number" if version < 1

      @version_number = version
    end

    def assign_resource_name(resource_name)
      fail "missing resource name" if resource_name.blank?

      if !resource_is_active_record_model?(resource_name)
        fail "resource is not an active record model"
      end

      @resource_name = resource_name
    end

    def resource_is_active_record_model?(resource_name)
      klass = resource_name.classify.constantize
      !!ActiveRecord::Base.descendants.find { |model_class| model_class == klass }
    rescue NameError
      false
    end
  end
end
