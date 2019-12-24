module PowerApi::GeneratorHelper::SwaggerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::VersionHelper
    include PowerApi::GeneratorHelper::ResourceHelper
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

  def swagger_schemas_path
    "spec/swagger/v#{version_number}/schemas/.gitkeep"
  end

  def swagger_resource_spec_path
    "spec/integration/api/v#{version_number}/#{plural_resource}_spec.rb"
  end

  def swagger_version_definition_path
    "spec/swagger/v#{version_number}/definition.rb"
  end

  def swagger_resource_schema_path
    "spec/swagger/v#{version_number}/schemas/#{snake_case_resource}_schema.rb"
  end

  def swagger_helper_api_definition_line
    "config.swagger_docs = {\n"
  end

  def swagger_definition_line_to_inject_schema
    /definitions: {/
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

  def swagger_definition_template
    <<~DEFINITION
      API_V#{version_number} = {
        swagger: '2.0',
        info: {
          title: 'API V#{version_number}',
          version: 'v#{version_number}'
        },
        basePath: '/api/v#{version_number}',
        definitions: {
        }
      }
    DEFINITION
  end

  def swagger_helper_api_definition
    content = "    'v#{version_number}/swagger.json' => API_V#{version_number}"
    content = "#{content}," unless first_version?
    "#{content}\n"
  end

  def get_swagger_schema_tpl
    <<~SCHEMA
      #{swagger_model_definition_const} = {
        type: :object,
        properties: {
          id: { type: :string, example: '1' },
          type: { type: :string, example: '#{snake_case_resource}' },
          attributes: {
            type: :object,
            properties: {#{get_swagger_schema_attributes_definitions}
            },
            required: [#{get_swagger_schema_attributes_names}
            ]
          }
        },
        required: [
          :id,
          :type,
          :attributes
        ]
      }

      #{swagger_collection_definition_const} = {
        type: "object",
        properties: {
          data: {
            type: "array",
            items: { "$ref" => "#/definitions/#{plural_resource}_collection" }
          }
        },
        required: [
          :data
        ]
      }

      #{swagger_resource_definition_const} = {
        type: "object",
        properties: {
          data: { "$ref" => "#/definitions/#{snake_case_resource}_resource" }
        },
        required: [
          :data
        ]
      }
    SCHEMA
  end

  def swagger_definition_entry
    [
      "\n    #{snake_case_resource}: #{swagger_model_definition_const},",
      "\n    #{plural_resource}_collection: #{swagger_collection_definition_const},",
      "\n    #{snake_case_resource}_resource: #{swagger_resource_definition_const},"
    ].join
  end

  private

  def swagger_model_definition_const
    "#{upcase_resource}_SCHEMA"
  end

  def swagger_collection_definition_const
    "#{upcase_plural_resource}_COLLECTION_SCHEMA"
  end

  def swagger_resource_definition_const
    "#{upcase_resource}_RESOURCE_SCHEMA"
  end

  def get_swagger_schema_attributes_definitions
    for_each_schema_attribute do |attr|
      "#{attr[:name]}: { type: :#{attr[:swagger_type]}, example: #{attr[:example]} },"
    end
  end

  def get_swagger_schema_attributes_names
    for_each_schema_attribute do |attr|
      ":#{attr[:name]},"
    end
  end

  def for_each_schema_attribute
    resource_attributes.inject("") do |memo, attr|
      memo += "\n        "
      memo += yield(attr)
      memo
    end.delete_suffix(",")
  end
end
