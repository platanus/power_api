describe PowerApi::GeneratorHelper::SwaggerHelper, type: :generator do
  describe "#swagger_helper_path" do
    let(:expected_path) { "spec/swagger_helper.rb" }

    def perform
      generators_helper.swagger_helper_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#spec_swagger_path" do
    let(:expected_path) { "spec/swagger/.gitkeep" }

    def perform
      generators_helper.spec_swagger_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#spec_integration_path" do
    let(:expected_path) { "spec/integration/.gitkeep" }

    def perform
      generators_helper.spec_integration_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#rswag_ui_initializer_path" do
    let(:expected_path) { "config/initializers/rswag-ui.rb" }

    def perform
      generators_helper.rswag_ui_initializer_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_resource_schema_path" do
    let(:expected_path) { "spec/swagger/v1/schemas/blog_schema.rb" }

    def perform
      generators_helper.swagger_resource_schema_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_version_definition_path" do
    let(:expected_path) { "spec/swagger/v1/definition.rb" }

    def perform
      generators_helper.swagger_version_definition_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_resource_spec_path" do
    let(:expected_path) { "spec/integration/api/v1/blogs_spec.rb" }

    def perform
      generators_helper.swagger_resource_spec_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#rswag_ui_configure_line" do
    let(:expected_path) do
      "Rswag::Ui.configure do |c|\n"
    end

    def perform
      generators_helper.rswag_ui_configure_line
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_helper_api_definition_line" do
    let(:expected_line) do
      "config.swagger_docs = {\n"
    end

    def perform
      generators_helper.swagger_helper_api_definition_line
    end

    it { expect(perform).to eq(expected_line) }
  end

  describe "#swagger_definition_line_to_inject_schema" do
    let(:expected_line) { /definitions: {/ }

    def perform
      generators_helper.swagger_definition_line_to_inject_schema
    end

    it { expect(perform).to eq(expected_line) }
  end

  describe "#swagger_helper_api_definition" do
    let(:expected_tpl) do
      <<-VERSION
    'v1/swagger.json' => API_V1
      VERSION
    end

    def perform
      generators_helper.swagger_helper_api_definition
    end

    it { expect(perform).to eq(expected_tpl) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<-VERSION
    'v2/swagger.json' => API_V2,
        VERSION
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end

  describe "#rswag_ui_initializer_tpl" do
    let(:expected_tpl) do
      <<~INITIALIZER
        Rswag::Ui.configure do |c|
        end
      INITIALIZER
    end

    def perform
      generators_helper.rswag_ui_initializer_tpl
    end

    it { expect(perform).to eq(expected_tpl) }
  end

  describe "#swagger_definition_tpl" do
    let(:expected_tpl) do
      <<~DEFINITION
        API_V1 = {
          swagger: '2.0',
          info: {
            title: 'API V1',
            version: 'v1'
          },
          basePath: '/api/v1',
          definitions: {
          }
        }
      DEFINITION
    end

    def perform
      generators_helper.swagger_definition_tpl
    end

    it { expect(perform).to eq(expected_tpl) }
  end

  describe "swagger_helper_tpl" do
    let(:template) do
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

    def perform
      generators_helper.swagger_helper_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "#swagger_schema_tpl" do
    let(:template) do
      <<~SCHEMA
        BLOG_SCHEMA = {
          type: :object,
          properties: {
        id: { type: :integer, example: 666 },
        title: { type: :string, example: 'Some title' },
        body: { type: :string, example: 'Some body' },
        created_at: { type: :string, example: '1984-06-04 09:00', 'x-nullable': true },
        updated_at: { type: :string, example: '1984-06-04 09:00', 'x-nullable': true },
        portfolio_id: { type: :integer, example: 666, 'x-nullable': true }
          },
          required: [
        :id,
        :title,
        :body
          ]
        }

        BLOGS_COLLECTION_SCHEMA = {
          type: "object",
          properties: {
            blogs: {
              type: "array",
              items: { "$ref" => "#/definitions/blog" }
            }
          },
          required: [
            :blogs
          ]
        }

        BLOG_RESOURCE_SCHEMA = {
          type: "object",
          properties: {
            blog: { "$ref" => "#/definitions/blog" }
          },
          required: [
            :blog
          ]
        }
      SCHEMA
    end

    def perform
      generators_helper.swagger_schema_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "#swagger_resource_spec_tpl" do
    let(:template) do
      <<~SPEC
        require 'swagger_helper'

        describe 'API V1 Blogs', swagger_doc: 'v1/swagger.json' do
        path '/blogs' do
        get 'Retrieves Blogs' do
        description 'Retrieves all the blogs'
        produces 'application/json'

        let(:collection_count) { 5 }
        let(:expected_collection_count) { collection_count }

        before { create_list(:blog, collection_count) }
        response '200', 'Blogs retrieved' do
        schema('$ref' => '#/definitions/blogs_collection')

        run_test! do |response|
        expect(JSON.parse(response.body)['blogs'].count).to eq(expected_collection_count)
        end
        end

        end

        post 'Creates Blog' do
        description 'Creates Blog'
        consumes 'application/json'
        produces 'application/json'
        parameter(name: :blog, in: :body)

        response '201', 'blog created' do
        let(:blog) do
        {
        title: 'Some title',
        body: 'Some body'}
        end

        run_test!
        end

        response '400', 'invalid attributes' do
        let(:blog) do
        {
        title: nil}
        end

        run_test!
        end

        end

        end

        path '/blogs/{id}' do
        parameter name: :id, in: :path, type: :integer

        let(:existent_blog) { create(:blog) }
        let(:id) { existent_blog.id }

        get 'Retrieves Blog' do
        produces 'application/json'

        response '200', 'blog retrieved' do
        schema('$ref' => '#/definitions/blog_resource')

        run_test!
        end

        response '404', 'invalid blog id' do
        let(:id) { 'invalid' }
        run_test!
        end

        end

        put 'Updates Blog' do
        description 'Updates Blog'
        consumes 'application/json'
        produces 'application/json'
        parameter(name: :blog, in: :body)

        response '200', 'blog updated' do
        let(:blog) do
        {
        title: 'Some title',
        body: 'Some body'}
        end

        run_test!
        end

        response '400', 'invalid attributes' do
        let(:blog) do
        {
        title: nil}
        end

        run_test!
        end

        end

        delete 'Deletes Blog' do
        produces 'application/json'
        description 'Deletes specific blog'

        response '204', 'blog deleted' do
        run_test!
        end

        response '404', 'blog not found' do
        let(:id) { 'invalid' }

        run_test!
        end

        end

        end

        end
      SPEC
    end

    def perform
      generators_helper.swagger_resource_spec_tpl
    end

    it { expect(perform).to eq(template) }

    context "with authenticated_resource option" do
      let(:authenticated_resource) { "user" }

      it { expect(perform).to include("let(:user) { create(:user) }") }
      it { expect(perform).to include("let(:user_email) { user.email }") }
      it { expect(perform).to include("let(:user_token) { user.authentication_token }") }
      it { expect(perform).to include("parameter name: :user_email, in: :query, type: :string") }
      it { expect(perform).to include("parameter name: :user_token, in: :query, type: :string") }
      it { expect(perform).to include("response '401', 'user unauthorized' do") }
    end

    context "with owned_by_authenticated_resource option" do
      let(:authenticated_resource) { "user" }
      let(:owned_by_authenticated_resource) { true }

      it { expect(perform).to include("create_list(:blog, collection_count, user: user)") }
      it { expect(perform).to include("(:existent_blog) { create(:blog, user: user) }") }
    end

    context "with parent_resource option" do
      let(:parent_resource_name) { "portfolio" }

      it { expect(perform).to include("/portfolios/{portfolio_id}/blogs") }
      it { expect(perform).to include("parameter name: :portfolio_id, in: :path, type: :integer") }
      it { expect(perform).to include("reate_list(:blog, collection_count, portfolio: portfolio)") }
      it { expect(perform).to include("let(:portfolio) { create(:portfolio) }") }
      it { expect(perform).to include("(:existent_blog) { create(:blog, portfolio: portfolio) }") }
    end

    context 'with only some resource actions (show and update)' do
      let(:controller_actions) do
        [
          "show",
          "update"
        ]
      end

      it { expect(perform).to include("path '/blogs/{id}' do\n") }
      it { expect(perform).to include("get 'Retrieves Blog' do\n") }
      it { expect(perform).to include("put 'Updates Blog' do\n") }
      it { expect(perform).not_to include("delete 'Deletes Blog' do\n") }
      it { expect(perform).not_to include("path '/blogs' do\n") }
      it { expect(perform).not_to include("get 'Retrieves Blogs' do\n") }
      it { expect(perform).not_to include("post 'Creates Blog' do\n") }
    end

    context 'with only some collection actions (index)' do
      let(:controller_actions) { ["index"] }

      it { expect(perform).not_to include("path '/blogs/{id}' do\n") }
      it { expect(perform).not_to include("get 'Retrieves Blog' do\n") }
      it { expect(perform).not_to include("put 'Updates Blog' do\n") }
      it { expect(perform).not_to include("delete 'Deletes Blog' do\n") }
      it { expect(perform).to include("path '/blogs' do\n") }
      it { expect(perform).to include("get 'Retrieves Blogs' do\n") }
      it { expect(perform).not_to include("post 'Creates Blog' do\n") }
    end
  end

  describe "#rswag_ui_swagger_endpoint" do
    let(:expected_entry) do
      "  c.swagger_endpoint '/api-docs/v1/swagger.json', 'API V1 Docs'\n"
    end

    def perform
      generators_helper.rswag_ui_swagger_endpoint
    end

    it { expect(perform).to eq(expected_entry) }
  end

  describe "#swagger_definition_entry" do
    let(:expected_entry) do
      "\n    blog: BLOG_SCHEMA,\
\n    blogs_collection: BLOGS_COLLECTION_SCHEMA,\
\n    blog_resource: BLOG_RESOURCE_SCHEMA,"
    end

    def perform
      generators_helper.swagger_definition_entry
    end

    it { expect(perform).to eq(expected_entry) }
  end
end
