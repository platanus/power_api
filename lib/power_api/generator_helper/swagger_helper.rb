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

  def rswag_ui_initializer_path
    "config/initializers/rswag-ui.rb"
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

  def rswag_ui_configure_line
    "Rswag::Ui.configure do |c|\n"
  end

  def swagger_helper_api_definition_line
    "config.swagger_docs = {\n"
  end

  def swagger_definition_line_to_inject_schema
    /definitions: {/
  end

  def rswag_ui_initializer_tpl
    <<~INITIALIZER
      Rswag::Ui.configure do |c|
      end
    INITIALIZER
  end

  def swagger_helper_tpl
    <<~SWAGGER
      require 'rails_helper'

      Dir[::Rails.root.join("spec/swagger/**/schemas/*.rb")].each { |f| require f }
      Dir[::Rails.root.join("spec/swagger/**/definition.rb")].each { |f| require f }

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

  def rswag_ui_swagger_endpoint
    "  c.swagger_endpoint '/api-docs/v#{version_number}/swagger.json', \
'API V#{version_number} Docs'\n"
  end

  def swagger_helper_api_definition
    content = "    'v#{version_number}/swagger.json' => API_V#{version_number}"
    content = "#{content}," unless first_version?
    "#{content}\n"
  end

  def swagger_definition_tpl
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

  def swagger_schema_tpl
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
            items: { "$ref" => "#/definitions/#{snake_case_resource}" }
          }
        },
        required: [
          :data
        ]
      }

      #{swagger_resource_definition_const} = {
        type: "object",
        properties: {
          data: { "$ref" => "#/definitions/#{snake_case_resource}" }
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

  def swagger_resource_spec_tpl
    template = ERB.new <<~SPEC
      require 'swagger_helper'

      describe 'API V#{version_number} #{plural_titleized_resource}', swagger_doc: 'v#{version_number}/swagger.json' do
        path '/#{plural_resource}' do
          get 'Retrieves #{plural_titleized_resource}' do
            description 'Retrieves all the #{plural_resource}'
            produces 'application/json'

            let(:collection_count) { 5 }
            let(:expected_collection_count) { collection_count }

            before { create_list(:#{resource_name}, collection_count) }

            response '200', 'retrieves #{plural_titleized_resource} collection' do
              schema('$ref' => '#/definitions/#{plural_resource}_collection')

              run_test! do |response|
                expect(JSON.parse(response.body)['data'].count).to eq(expected_collection_count)
              end
            end
          end

          post 'Creates #{titleized_resource}' do
            description 'Creates #{titleized_resource}'
            consumes 'application/json'
            produces 'application/json'
            parameter(name: :#{resource_name}, in: :body, schema: { '$ref' => '#/definitions/#{resource_name}_params' })

            response '201', '#{resource_name} created' do
              let(:#{resource_name}) do
                {#{resource_params}
                }
              end

              run_test!
            end

            <% if required_resource_attributes.any? %>response '400', 'invalid attributes' do
              let(:#{resource_name}) do
                {#{invalid_resource_params}
                }
              end

              run_test!
            end<% end %>
          end
        end

        path '/#{plural_resource}/{id}' do
          parameter name: :id, in: :path, type: :integer

          let(:existent_#{resource_name}) { create(:#{resource_name}) }
          let(:id) { existent_#{resource_name}.id }

          get 'Retrieves #{titleized_resource}' do
            produces 'application/json'
            description 'Retrieves #{resource_name} specific data'

            response '200', '#{resource_name} retrieved' do
              schema('$ref' => '#/definitions/#{resource_name}_resource')

              run_test!
            end

            response '404', 'invalid #{resource_name} id' do
              let(:id) { 'invalid' }

              run_test!
            end
          end

          put 'Updates #{titleized_resource}' do
            description 'Updates #{titleized_resource}'
            consumes 'application/json'
            produces 'application/json'
            parameter(name: :#{resource_name}, in: :body, schema: { '$ref' => '#/definitions/#{resource_name}_params' })

            response '200', '#{resource_name} updated' do
              let(:#{resource_name}) do
                {#{resource_params}
                }
              end

              run_test!
            end

            <% if required_resource_attributes.any? %>response '400', 'invalid attributes' do
              let(:#{resource_name}) do
                {#{invalid_resource_params}
                }
              end

              run_test!
            end<% end %>
          end

          delete 'Deletes #{titleized_resource}' do
            produces 'application/json'
            description 'Deletes specific #{resource_name}'

            response '204', '#{resource_name} deleted' do
              run_test!
            end

            response '404', 'with invalid #{resource_name} id' do
              let(:id) { 'invalid' }

              run_test!
            end
          end
        end
      end
    SPEC

    template.result(binding)
  end

  private

  def resource_params
    for_each_schema_attribute(required_resource_attributes, margin_spaces: 12) do |attr|
      "#{attr[:name]}: #{attr[:example]},"
    end
  end

  def invalid_resource_params
    for_each_schema_attribute([required_resource_attributes.first], margin_spaces: 12) do |attr|
      "#{attr[:name]}: nil,"
    end
  end

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
    for_each_schema_attribute(resource_attributes, margin_spaces: 8) do |attr|
      "#{attr[:name]}: { type: :#{attr[:swagger_type]}, example: #{attr[:example]} },"
    end
  end

  def get_swagger_schema_attributes_names
    for_each_schema_attribute(required_resource_attributes, margin_spaces: 8) do |attr|
      ":#{attr[:name]},"
    end
  end

  def for_each_schema_attribute(attributes, margin_spaces: 0)
    attributes.inject("") do |memo, attr|
      memo += "\n" + " " * margin_spaces
      memo += yield(attr)
      memo
    end.delete_suffix(",")
  end
end
