module PowerApi
  class InstallGeneratorHelper
    def api_base_controller_path
      "app/controllers/api/base_controller.rb"
    end

    def api_base_controller_tpl
      <<~CONTROLLER
        class Api::BaseController < PowerApi::BaseController
        end
      CONTROLLER
    end

    def ams_initializer_path
      "config/initializers/active_model_serializers.rb"
    end

    def ams_initializer_tpl
      <<~INITIALIZER
        class ActiveModelSerializers::Adapter::JsonApi
          def self.default_key_transform
            :unaltered
          end
        end

        ActiveModelSerializers.config.adapter = :json_api
      INITIALIZER
    end

    def swagger_helper_path
      "spec/swagger_helper.rb"
    end

    def spec_swagger_path
      "spec/swagger/.gitkeep"
    end

    def spec_integration_path
      "spec/integration/.gitkeep"
    end

    def swagger_helper_tpl
      <<~SWAGGER
        require 'rails_helper'

        Dir[Rails.root.join("spec", "swagger", "**", "*.rb")].each { |f| require f }

        RSpec.configure do |config|
          # Specify a root folder where Swagger JSON files are generated
          # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
          # to ensure that it's confiugred to serve Swagger from the same folder
          config.swagger_root = Rails.root.to_s + '/swagger'

          # Define one or more Swagger documents and provide global metadata for each one
          # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
          # be generated at the provided relative path under swagger_root
          # By default, the operations defined in spec files are added to the first
          # document below. You can override this behavior by adding a swagger_doc tag to the
          # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
          config.swagger_docs = {
          }
        end
      SWAGGER
    end

    def api_pagination_tpl_path
      "config/initializers/api_pagination.rb"
    end

    def api_pagination_tpl
      <<~API_PAGINATION
        ApiPagination.configure do |config|
          # If you have more than one gem included, you can choose a paginator.
          config.paginator = :kaminari

          # By default, this is set to 'Total'
          config.total_header = 'X-Total'

          # By default, this is set to 'Per-Page'
          config.per_page_header = 'X-Per-Page'

          # Optional: set this to add a header with the current page number.
          config.page_header = 'X-Page'

          # Optional: set this to add other response format. Useful with tools that define :jsonapi format
          # config.response_formats = [:json, :xml, :jsonapi]
          config.response_formats = [:jsonapi]

          # Optional: what parameter should be used to set the page option
          config.page_param do |params|
            params[:page][:number] if params[:page].is_a?(ActionController::Parameters)
          end

          # Optional: what parameter should be used to set the per page option
          config.per_page_param do |params|
            params[:page][:size] if params[:page].is_a?(ActionController::Parameters)
          end

          # Optional: Include the total and last_page link header
          # By default, this is set to true
          # Note: When using kaminari, this prevents the count call to the database
          config.include_total = true
        end
      API_PAGINATION
    end
  end
end
