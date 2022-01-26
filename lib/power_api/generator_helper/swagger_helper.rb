# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Layout/AlignParameters
module PowerApi::GeneratorHelper::SwaggerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::ApiHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::SimpleTokenAuthHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper
    include PowerApi::GeneratorHelper::ControllerActionsHelper
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
    "spec/integration/api/v#{version_number}/#{resource.plural}_spec.rb"
  end

  def swagger_version_definition_path
    "spec/swagger/v#{version_number}/definition.rb"
  end

  def swagger_resource_schema_path
    "spec/swagger/v#{version_number}/schemas/#{resource.snake_case}_schema.rb"
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
        properties: {#{get_swagger_schema_attributes_definitions}
        },
        required: [#{get_swagger_schema_attributes_names}
        ]
      }

      #{swagger_collection_definition_const} = {
        type: "object",
        properties: {
          #{resource.plural}: {
            type: "array",
            items: { "$ref" => "#/definitions/#{resource.snake_case}" }
          }
        },
        required: [
          :#{resource.plural}
        ]
      }

      #{swagger_resource_definition_const} = {
        type: "object",
        properties: {
          #{resource.snake_case}: { "$ref" => "#/definitions/#{resource.snake_case}" }
        },
        required: [
          :#{resource.snake_case}
        ]
      }
    SCHEMA
  end

  def swagger_definition_entry
    [
      "\n    #{resource.snake_case}: #{swagger_model_definition_const},",
      "\n    #{resource.plural}_collection: #{swagger_collection_definition_const},",
      "\n    #{resource.snake_case}_resource: #{swagger_resource_definition_const},"
    ].join
  end

  def swagger_resource_spec_tpl
    concat_tpl_statements(
      "require 'swagger_helper'\n",
      concat_tpl_statements(
        spec_tpl_initial_describe_line,
        spec_tpl_authenticated_resource,
        spec_tpl_let_parent_resource,
        spec_tpl_collection_path_statements,
        spec_tpl_resource_path_statements,
        "end\n"
      )
    )
  end

  private

  def spec_tpl_initial_describe_line
    "describe 'API V#{version_number} #{resource.plural_titleized}', \
swagger_doc: 'v#{version_number}/swagger.json' do"
  end

  def spec_tpl_authenticated_resource
    return unless authenticated_resource?

    res_name = authenticated_resource.snake_case
    concat_tpl_statements(
      "let(:#{res_name}) { create(:#{res_name}) }",
      "let(:#{res_name}_email) { #{res_name}.email }",
      "let(:#{res_name}_token) { #{res_name}.authentication_token }\n"
    )
  end

  def spec_tpl_collection_path_statements
    return unless collection_actions?

    concat_tpl_statements(
      "path '/#{spec_tpl_collection_path}' do",
        spec_tpl_parent_resource_parameter,
        spec_tpl_authenticated_resource_params,
        spec_tpl_index,
        spec_tpl_create,
      "end\n"
    )
  end

  def spec_tpl_collection_path
    return resource.plural unless parent_resource?

    "#{parent_resource.plural}/{#{parent_resource.id}}/#{resource.plural}"
  end

  def spec_tpl_resource_path_statements
    return unless resource_actions?

    concat_tpl_statements(
      "path '/#{resource.plural}/{id}' do",
        spec_tpl_authenticated_resource_params,
        spec_tpl_let_existent_resource,
        spec_tpl_show,
        spec_tpl_update,
        spec_tpl_destroy,
      "end\n"
    )
  end

  def spec_tpl_let_existent_resource
    statement = ["let(:existent_#{resource.snake_case}) { create(:#{resource.snake_case}"]
    load_owner_resource_option(statement)

    concat_tpl_statements(
      "parameter name: :id, in: :path, type: :integer\n",
      "#{statement.join(', ')}) }",
      "let(:id) { existent_#{resource.snake_case}.id }\n"
    )
  end

  def spec_tpl_authenticated_resource_params
    return unless authenticated_resource?

    res_name = authenticated_resource.snake_case
    concat_tpl_statements(
      "parameter name: :#{res_name}_email, in: :query, type: :string",
      "parameter name: :#{res_name}_token, in: :query, type: :string\n"
    )
  end

  def spec_tpl_index
    return unless index?

    concat_tpl_statements(
      "get 'Retrieves #{resource.plural_titleized}' do",
        "description 'Retrieves all the #{resource.plural}'",
        "produces 'application/json'\n",
        "let(:collection_count) { 5 }",
        "let(:expected_collection_count) { collection_count }\n",
        "before { #{spec_tpl_index_creation_list} }",
        "response '200', '#{resource.plural_titleized} retrieved' do",
          "schema('$ref' => '#/definitions/#{resource.plural}_collection')\n",
          "run_test! do |response|",
            "expect(JSON.parse(response.body)['#{resource.plural}'].count).to eq(expected_collection_count)",
          "end",
        "end\n",
        spec_tpl_invalid_credentials,
      "end\n"
    )
  end

  def spec_tpl_index_creation_list
    statement = ["create_list(:#{resource.snake_case}, collection_count"]
    load_owner_resource_option(statement)
    statement.join(', ') + ')'
  end

  def load_owner_resource_option(statement)
    if parent_resource?
      statement << "#{parent_resource.snake_case}: #{parent_resource.snake_case}"
    end

    if owned_by_authenticated_resource?
      statement << "#{authenticated_resource.snake_case}: #{authenticated_resource.snake_case}"
    end
  end

  def spec_tpl_create
    return unless create?

    concat_tpl_statements(
      "post 'Creates #{resource.titleized}' do",
        "description 'Creates #{resource.titleized}'",
        "consumes 'application/json'",
        "produces 'application/json'",
        "parameter(name: :#{resource.snake_case}, in: :body)\n",
        "response '201', '#{resource.snake_case} created' do",
          "let(:#{resource.snake_case}) do",
            "{#{resource_params}}",
          "end\n",
          "run_test!",
        "end\n",
        spec_tpl_create_invalid_attrs_test,
        spec_tpl_invalid_credentials(with_body: true),
      "end\n"
    )
  end

  def spec_tpl_parent_resource_parameter
    return unless parent_resource?

    "parameter name: :#{parent_resource.id}, in: :path, type: :integer"
  end

  def spec_tpl_let_parent_resource
    return unless parent_resource?

    concat_tpl_statements(
      "let(:#{parent_resource.snake_case}) { create(:#{parent_resource.snake_case}) }",
      "let(:#{parent_resource.id}) { #{parent_resource.snake_case}.id }\n"
    )
  end

  def spec_tpl_show
    return unless show?

    concat_tpl_statements(
      "get 'Retrieves #{resource.titleized}' do",
        "produces 'application/json'\n",
        "response '200', '#{resource.snake_case} retrieved' do",
          "schema('$ref' => '#/definitions/#{resource.snake_case}_resource')\n",
          "run_test!",
        "end\n",
        "response '404', 'invalid #{resource.snake_case} id' do",
          "let(:id) { 'invalid' }",
          "run_test!",
        "end\n",
        spec_tpl_invalid_credentials,
      "end\n"
    )
  end

  def spec_tpl_update
    return unless update?

    concat_tpl_statements(
      "put 'Updates #{resource.titleized}' do",
        "description 'Updates #{resource.titleized}'",
        "consumes 'application/json'",
        "produces 'application/json'",
        "parameter(name: :#{resource.snake_case}, in: :body)\n",
          "response '200', '#{resource.snake_case} updated' do",
          "let(:#{resource.snake_case}) do",
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
    return unless destroy?

    concat_tpl_statements(
      "delete 'Deletes #{resource.titleized}' do",
        "produces 'application/json'",
        "description 'Deletes specific #{resource.snake_case}'\n",
        "response '204', '#{resource.snake_case} deleted' do",
          "run_test!",
        "end\n",
        "response '404', '#{resource.snake_case} not found' do",
          "let(:id) { 'invalid' }\n",
          "run_test!",
        "end\n",
        spec_tpl_invalid_credentials,
      "end\n"
    )
  end

  def spec_tpl_invalid_credentials(with_body: false)
    return unless authenticated_resource?

    authenticated_resource_name = authenticated_resource.snake_case
    concat_tpl_statements(
      "response '401', '#{authenticated_resource_name} unauthorized' do",
        with_body ? "let(:#{resource.snake_case}) { {} }" : nil,
        "let(:user_token) { 'invalid' }\n",
        "run_test!",
      "end\n"
    )
  end

  def spec_tpl_update_invalid_attrs_test
    spec_tpl_create_invalid_attrs_test
  end

  def spec_tpl_create_invalid_attrs_test
    return if resource.required_resource_attributes.blank?

    concat_tpl_statements(
      "response '400', 'invalid attributes' do",
        "let(:#{resource.snake_case}) do",
          "{#{invalid_resource_params}}",
        "end\n",
        "run_test!",
      "end\n"
    )
  end

  def resource_params
    attrs = if resource.required_resource_attributes.any?
              resource.required_resource_attributes
            else
              resource.optional_resource_attributes
            end

    for_each_schema_attribute(attrs) do |attr|
      "#{attr[:name]}: #{attr[:example]},"
    end
  end

  def invalid_resource_params
    return unless resource.required_resource_attributes.any?

    for_each_schema_attribute([resource.required_resource_attributes.first]) do |attr|
      "#{attr[:name]}: nil,"
    end
  end

  def swagger_model_definition_const
    "#{resource.upcase}_SCHEMA"
  end

  def swagger_collection_definition_const
    "#{resource.upcase_plural}_COLLECTION_SCHEMA"
  end

  def swagger_resource_definition_const
    "#{resource.upcase}_RESOURCE_SCHEMA"
  end

  def get_swagger_schema_attributes_definitions
    for_each_schema_attribute(resource.resource_attributes) do |attr|
      opts = ["example: #{attr[:example]}"]
      opts << "'x-nullable': true" unless attr[:required]
      opts

      "#{attr[:name]}: { type: :#{attr[:swagger_type]}, #{opts.join(', ')} },"
    end
  end

  def get_swagger_schema_attributes_names
    for_each_schema_attribute(resource.required_resource_attributes) do |attr|
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
# rubocop:enable Layout/AlignParameters
