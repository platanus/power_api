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
  end
end
