# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Layout/AlignParameters
module PowerApi::GeneratorHelper::RspecControllerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::ApiHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper
  end

  def resource_spec_path
    "spec/requests/#{api_file_path}/#{resource.plural}_spec.rb"
  end

  def resource_spec_tpl
    concat_tpl_statements(
      "require 'rails_helper'\n",
      concat_tpl_statements(
        spec_initial_describe_line,
        spec_authenticated_resource_tpl,
        spec_let_parent_resource_tpl,
        spec_index_tpl,
        spec_create_tpl,
        spec_show_tpl,
        spec_update_tpl,
        spec_destroy_tpl,
        "end\n"
      )
    )
  end

  private

  def spec_initial_describe_line
    "RSpec.describe '#{api_class}::#{resource.camel_plural}Controllers', type: :request do"
  end

  def spec_authenticated_resource_tpl
    return unless authenticated_resource?

    res_name = authenticated_resource.snake_case
    "let(:#{res_name}) { create(:#{res_name}) }"
  end

  def spec_let_parent_resource_tpl
    return unless parent_resource?

    concat_tpl_statements(
      "let(:#{parent_resource.snake_case}) { create(:#{parent_resource.snake_case}) }",
      "let(:#{parent_resource.id}) { #{parent_resource.snake_case}.id }\n"
    )
  end

  def spec_index_tpl
    return unless index?

    concat_tpl_statements(
      "describe 'GET /index' do",
        "let!(:#{resource.plural}) { #{spec_index_creation_list_tpl} }",
        "let(:collection) { JSON.parse(response.body)['data'] }",
        "let(:params) { {} }\n",
        spec_perform_tpl,
        with_authorized_resource_context,
        perform_block_tpl,
        "it { expect(collection.count).to eq(5) }",
        "it { expect(response.status).to eq(200) }",
        conditional_code(authenticated_resource?) { "end\n" },
        unauthorized_spec_tpl,
        "end\n"
    )
  end

  def spec_create_tpl
    return unless create?

    concat_tpl_statements(
      "describe 'POST /create' do",
      "let(:params) do",
        "{",
          "#{resource.snake_case}: {#{resource_parameters}",
          "}",
        "}",
      "end\n",
      let_resource_attrs,
      spec_perform_tpl(http_verb: 'post'),
      with_authorized_resource_context,
      perform_block_tpl,
      "it { expect(attributes).to include(params[:#{resource.snake_case}]) }",
      "it { expect(response.status).to eq(201) }",
      spec_invalid_attrs_test_tpl,
      conditional_code(authenticated_resource?) { "end\n" },
      unauthorized_spec_tpl,
      "end\n"
    )
  end

  def spec_show_tpl
    return unless show?

    concat_tpl_statements(
      "describe 'GET /show' do",
      spec_let_existent_resource_tpl,
      "let(:#{resource.snake_case}_id) { #{resource.snake_case}.id.to_s }\n",
      let_resource_attrs,
      spec_perform_tpl(http_verb: 'get', params: false, single_resource: true),
      with_authorized_resource_context,
      perform_block_tpl,
      "it { expect(response.status).to eq(200) }",
      "context 'with resource not found' do",
      "let(:#{resource.snake_case}_id) { '666' }",
      "it { expect(response.status).to eq(404) }",
      "end",
      conditional_code(authenticated_resource?) { "end\n" },
      unauthorized_spec_tpl,
      "end\n"
    )
  end

  def spec_update_tpl
    return unless update?

    concat_tpl_statements(
      "describe 'PUT /update' do",
      spec_let_existent_resource_tpl,
      "let(:#{resource.snake_case}_id) { #{resource.snake_case}.id.to_s }\n",
      "let(:params) do",
        "{",
          "#{resource.snake_case}: {#{resource_parameters}",
          "}",
        "}",
      "end\n",
      let_resource_attrs,
      spec_perform_tpl(http_verb: 'put', params: true, single_resource: true),
      with_authorized_resource_context,
      perform_block_tpl,
      "it { expect(attributes).to include(params[:#{resource.snake_case}]) }",
      "it { expect(response.status).to eq(200) }",
      spec_invalid_attrs_test_tpl,
      "context 'with resource not found' do",
      "let(:#{resource.snake_case}_id) { '666' }",
      "it { expect(response.status).to eq(404) }",
      "end",
      conditional_code(authenticated_resource?) { "end\n" },
      unauthorized_spec_tpl,
      "end\n"
    )
  end

  def spec_destroy_tpl
    return unless destroy?

    concat_tpl_statements(
      "describe 'DELETE /destroy' do",
      spec_let_existent_resource_tpl,
      "let(:#{resource.snake_case}_id) { #{resource.snake_case}.id.to_s }\n",
      spec_perform_tpl(http_verb: 'get', params: false, single_resource: true),
      with_authorized_resource_context,
      perform_block_tpl,
      "it { expect(response.status).to eq(200) }",
      "context 'with resource not found' do",
      "let(:#{resource.snake_case}_id) { '666' }",
      "it { expect(response.status).to eq(404) }",
      "end",
      conditional_code(authenticated_resource?) { "end\n" },
      unauthorized_spec_tpl,
      "end\n"
    )
  end

  def spec_let_existent_resource_tpl
    statement = ["let(:#{resource.snake_case}) { create(:#{resource.snake_case}"]
    load_owner_resource_factory_option(statement)
    statement.join(', ') + ') }'
  end

  def spec_invalid_attrs_test_tpl
    return if resource.required_resource_attributes.blank?

    concat_tpl_statements(
      "context 'with invalid attributes' do",
        "let(:params) do",
          "{",
            "#{resource.snake_case}: {#{invalid_resource_params}}",
          "}",
        "end\n",
        "it { expect(response.status).to eq(400) }",
      "end\n"
    )
  end

  def with_authorized_resource_context
    conditional_code(authenticated_resource?) do
      "context 'with authorized #{authenticated_resource.snake_case}' do"
    end
  end

  def let_resource_attrs
    concat_tpl_statements(
      "let(:attributes) do",
        "JSON.parse(response.body)['data']['attributes'].symbolize_keys",
      "end"
    )
  end

  def perform_block_tpl(auth: true)
    concat_tpl_statements(
      "before do",
        conditional_code(auth && authenticated_resource?) do
          "sign_in(#{authenticated_resource.snake_case})"
        end,
        "perform",
      "end\n"
    )
  end

  def spec_perform_tpl(http_verb: 'get', params: true, single_resource: false)
    body = "#{http_verb} '/#{spec_collection_path(single_resource)}"
    body += "/' + #{resource.snake_case}_id" if single_resource
    body += "'" unless single_resource
    body += ", params: params" if params

    concat_tpl_statements(
      "def perform",
      body,
      "end\n"
    )
  end

  def spec_collection_path(single_resource)
    path = ["api"]
    path << (versioned_api? ? "v#{version_number}" : "internal")

    if parent_resource? && !single_resource
      path << parent_resource.plural
      path << "' + #{parent_resource.snake_case}.id.to_s + '"
    end

    path << resource.plural
    path.join("/")
  end

  def spec_index_creation_list_tpl
    statement = ["create_list(:#{resource.snake_case}, 5"]
    load_owner_resource_factory_option(statement)
    statement.join(', ') + ')'
  end

  def load_owner_resource_factory_option(statement)
    if parent_resource?
      statement << "#{parent_resource.snake_case}: #{parent_resource.snake_case}"
    end

    if owned_by_authenticated_resource?
      statement << "#{authenticated_resource.snake_case}: #{authenticated_resource.snake_case}"
    end
  end

  def unauthorized_spec_tpl
    return unless authenticated_resource?

    authenticated_resource_name = authenticated_resource.snake_case
    concat_tpl_statements(
      "context 'with unauthenticated #{authenticated_resource_name}' do",
        "before { perform }\n",
        "it { expect(response.status).to eq(401) }",
      "end\n"
    )
  end

  def resource_parameters
    attrs = if resource.required_resource_attributes.any?
              resource.required_resource_attributes
            else
              resource.optional_resource_attributes
            end

    for_each_attribute(attrs) do |attr|
      "#{attr[:name]}: #{attr[:example]},"
    end
  end

  def for_each_attribute(attributes)
    attributes.inject("") do |memo, attr|
      next memo if parent_resource && attr[:name] == parent_resource.id.to_sym

      memo += "\n"
      memo += yield(attr)
      memo
    end.delete_suffix(",")
  end
end
# rubocop:enable Metrics/ModuleLength
# rubocop:enable Metrics/MethodLength
# rubocop:enable Layout/AlignParameters
