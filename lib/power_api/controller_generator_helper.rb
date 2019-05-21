module PowerApi
  class ControllerGeneratorHelper
    attr_reader :version_number, :resource_name

    def initialize(config)
      assign_version_number(config[:version_number])
      assign_resource_name(config[:resource_name])
    end

    def generate_controller_tpl
      <<~CONTROLLER
        class Api::V#{version_number}::#{camel_resource}Controller < Api::V#{version_number}::BaseController
          def index
            respond_with #{camel_resource}.all
          end

          def show
            respond_with #{snake_case_resource}
          end

          def create
            respond_with #{camel_resource}.create!(#{snake_case_resource}_params)
          end

          def update
            respond_with #{snake_case_resource}.update!(#{snake_case_resource}_params)
          end

          def destroy
            #{snake_case_resource}.destroy!
          end

          private

          def #{snake_case_resource}
            @#{snake_case_resource} ||= #{camel_resource}.find_by!(id: params[:id])
          end

          def #{snake_case_resource}_params
            params.require(:#{snake_case_resource}).permit(:name)
          end
        end
      CONTROLLER
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
