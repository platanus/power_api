module PowerApi
  class VersionGeneratorHelper
    include VersionHelper
    include SwaggerHelper

    def initialize(config)
      self.version_number = config[:version_number]
    end

    def routes_line_to_inject_new_version
      return "routes.draw do\n" if first_version?

      "'/api' do\n"
    end

    def version_route_template
      return first_version_route_template if first_version?

      new_version_route_template
    end

    def first_version_route_template
      <<-ROUTE
  scope path: '/api' do
    api_version(#{api_version_params}) do
    end
  end
      ROUTE
    end

    def new_version_route_template
      <<-ROUTE
    api_version(#{api_version_params}) do
    end

      ROUTE
    end

    def api_version_params
      "module: 'Api::V#{version_number}', \
path: { value: 'v#{version_number}' }, \
defaults: { format: 'json' }"
    end

    def base_controller_path
      "app/controllers/api/v#{version_number}/base_controller.rb"
    end

    def base_controller_template
      <<~CONTROLLER
        class Api::V#{version_number}::BaseController < Api::BaseController
          before_action do
            self.namespace_for_serializer = ::Api::V#{version_number}
          end
        end
      CONTROLLER
    end

    def serializers_path
      "app/serializers/api/v#{version_number}/.gitkeep"
    end
  end
end
