# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Layout/AlignArguments
module PowerApi::GeneratorHelper::SwaggerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::VersionHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper
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
    concat_tpl_statements(
      "require 'swagger_helper'\n",
      concat_tpl_statements(
        spec_tpl_initial_describe_line,
        spec_tpl_authenticated_resource,
        spec_tpl_collection_path,
        spec_tpl_resource_path,
        "end\n"
      )
    )
  end

  private

  def spec_tpl_initial_describe_line
    "describe 'API V#{version_number} #{plural_titleized_resource}', \
swagger_doc: 'v#{version_number}/swagger.json' do"
  end

  def spec_tpl_authenticated_resource
    return unless authenticated_resource?

    res_name = authenticated_resource.resource_name
    concat_tpl_statements(
      "let(:#{res_name}) { create(:#{res_name}) }",
      "let(:#{res_name}_email) { #{res_name}.email }",
      "let(:#{res_name}_token) { #{res_name}.authentication_token }\n"
    )
  end

  def spec_tpl_collection_path
    concat_tpl_statements(
      "path '/#{plural_resource}' do",
        spec_tpl_authenticated_resource_params,
        spec_tpl_index,
        spec_tpl_create,
      "end\n"
    )
  end

  def spec_tpl_resource_path
    concat_tpl_statements(
      "path '/#{plural_resource}/{id}' do",
        spec_tpl_authenticated_resource_params,
        "parameter name: :id, in: :path, type: :integer",
        "let(:existent_#{resource_name}) { create(:#{resource_name}) }",
        "let(:id) { existent_#{resource_name}.id }\n",
        spec_tpl_resource_asigned_to_authenticated,
        spec_tpl_show,
        spec_tpl_update,
        spec_tpl_destroy,
      "end\n"
    )
  end

  def spec_tpl_authenticated_resource_params
    return unless authenticated_resource?

    res_name = authenticated_resource.resource_name
    concat_tpl_statements(
      "parameter name: :#{res_name}_email, in: :query, type: :string",
      "parameter name: :#{res_name}_token, in: :query, type: :string\n"
    )
  end

  def spec_tpl_index
    concat_tpl_statements(
      "get 'Retrieves #{plural_titleized_resource}' do",
        "description 'Retrieves all the #{plural_resource}'",
        "produces 'application/json'\n",
        "let(:collection_count) { 5 }",
        "let(:expected_collection_count) { collection_count }\n",
        "before { #{spec_tpl_index_creation_list} }",
        "response '200', '#{plural_titleized_resource} retrieved' do",
          "schema('$ref' => '#/definitions/#{plural_resource}_collection')\n",
          "run_test! do |response|",
            "expect(JSON.parse(response.body)['data'].count).to eq(expected_collection_count)",
          "end",
        "end\n",
        spec_tpl_invalid_credentials,
      "end\n"
    )
  end

  def spec_tpl_index_creation_list
    list = "create_list(:#{resource_name}, collection_count)"

    if owned_by_authenticated_resource?
      authenticated_resource_name = authenticated_resource.resource_name

      return "#{authenticated_resource_name}.#{plural_resource} = #{list}"
    end

    list
  end

  def spec_tpl_resource_asigned_to_authenticated
    return unless owned_by_authenticated_resource?

    authenticated_resource_name = authenticated_resource.resource_name
    "before { #{authenticated_resource_name}.#{plural_resource} << existent_#{resource_name} }"
  end

  def spec_tpl_create
    concat_tpl_statements(
      "post 'Creates #{titleized_resource}' do",
        "description 'Creates #{titleized_resource}'",
        "consumes 'application/json'",
        "produces 'application/json'",
        "parameter(name: :#{resource_name}, in: :body)\n",
        "response '201', '#{resource_name} created' do",
          "let(:#{resource_name}) do",
            "{#{resource_params}}",
          "end\n",
          "run_test!",
        "end\n",
        spec_tpl_create_invalid_attrs_test,
        spec_tpl_invalid_credentials(with_body: true),
      "end\n"
    )
  end

  def spec_tpl_show
    concat_tpl_statements(
      "get 'Retrieves #{titleized_resource}' do",
        "produces 'application/json'\n",
        "response '200', '#{resource_name} retrieved' do",
          "schema('$ref' => '#/definitions/#{resource_name}_resource')\n",
          "run_test!",
        "end\n",
        "response '404', 'invalid #{resource_name} id' do",
          "let(:id) { 'invalid' }",
          "run_test!",
        "end\n",
        spec_tpl_invalid_credentials,
      "end\n"
    )
  end

  def spec_tpl_update
    concat_tpl_statements(
      "put 'Updates #{titleized_resource}' do",
        "description 'Updates #{titleized_resource}'",
        "consumes 'application/json'",
        "produces 'application/json'",
        "parameter(name: :#{resource_name}, in: :body)\n",
          "response '200', '#{resource_name} updated' do",
          "let(:#{resource_name}) do",
            "{#{resource_params}}",
          "end\n",
          "run_test!",
        "end\n",
        spec_tpl_update_invalid_attrs_test,
        spec_tpl_invalid_credentials(with_body: true),
      "end\n"
    )
  end

  def spec_tpl_destroy
    concat_tpl_statements(
      "delete 'Deletes #{titleized_resource}' do",
        "produces 'application/json'",
        "description 'Deletes specific #{resource_name}'\n",
        "response '204', '#{resource_name} deleted' do",
          "run_test!",
        "end\n",
        "response '404', '#{resource_name} not found' do",
          "let(:id) { 'invalid' }\n",
          "run_test!",
        "end\n",
        spec_tpl_invalid_credentials,
      "end\n"
    )
  end

  def spec_tpl_invalid_credentials(with_body: false)
    return unless authenticated_resource?

    authenticated_resource_name = authenticated_resource.resource_name
    concat_tpl_statements(
      "response '401', '#{authenticated_resource_name} unauthorized' do",
        with_body ? "let(:#{resource_name}) { {} }" : nil,
        "let(:user_token) { 'invalid' }\n",
        "run_test!",
      "end\n"
    )
  end

  def spec_tpl_update_invalid_attrs_test
    spec_tpl_create_invalid_attrs_test
  end

  def spec_tpl_create_invalid_attrs_test
    return if required_resource_attributes.blank?

    concat_tpl_statements(
      "response '400', 'invalid attributes' do",
        "let(:#{resource_name}) do",
          "{#{invalid_resource_params}}",
        "end\n",
        "run_test!",
      "end\n"
    )
  end

  def resource_params
    attrs = if required_resource_attributes.any?
              required_resource_attributes
            else
              optional_resource_attributes
            end

    for_each_schema_attribute(attrs) do |attr|
      "#{attr[:name]}: #{attr[:example]},"
    end
  end

  def invalid_resource_params
    return unless required_resource_attributes.any?

    for_each_schema_attribute([required_resource_attributes.first]) do |attr|
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
    for_each_schema_attribute(resource_attributes) do |attr|
      opts = ["example: #{attr[:example]}"]
      opts << "'x-nullable': true" unless attr[:required]
      opts

      "#{attr[:name]}: { type: :#{attr[:swagger_type]}, #{opts.join(', ')} },"
    end
  end

  def get_swagger_schema_attributes_names
    for_each_schema_attribute(required_resource_attributes) do |attr|
      ":#{attr[:name]},"
    end
  end

  def for_each_schema_attribute(attributes)
    attributes.inject("") do |memo, attr|
      memo += "\n"
      memo += yield(attr)
      memo
    end.delete_suffix(",")
  end
end
# rubocop:enable Metrics/ModuleLength
# rubocop:enable Metrics/MethodLength
# rubocop:enable Layout/AlignArguments
