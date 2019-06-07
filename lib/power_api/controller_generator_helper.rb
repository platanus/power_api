module PowerApi
  class ControllerGeneratorHelper
    include ResourceHelper
    include VersionHelper

    attr_reader :version_number, :resource_name

    def initialize(config)
      validate_version_number!(config[:version_number])
      @version_number = config[:version_number]
      validate_resource_name!(config[:resource_name])
      @resource_name = config[:resource_name]
    end

    def get_controller_path
      "app/controllers/api/v#{version_number}/#{plural_resource}_controller.rb"
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

    def routes_line_to_inject_resource
      /Api::V#{version_number}[^\n]*/
    end

    def resource_route_template
      "\n      resources :#{plural_resource}"
    end
  end
end
