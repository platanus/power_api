describe PowerApi::SwaggerHelper do
  subject(:instance) { TestClass.new(init_params) }

  let(:version_number) { "1" }
  let(:resource_name) { "blog" }
  let(:resource_attributes) { nil }

  let(:init_params) do
    {
      version_number: version_number,
      resource_name: resource_name,
      resource_attributes: resource_attributes
    }
  end

  let(:class_definition) do
    Proc.new do
      include ::PowerApi::SwaggerHelper

      def initialize(config)
        self.version_number = config[:version_number]
        self.resource_name = config[:resource_name]
        self.resource_attributes = config[:resource_attributes]
      end
    end
  end

  before { create_test_class(&class_definition) }

  describe "#swagger_helper_path" do
    let(:expected_path) { "spec/swagger_helper.rb" }

    def perform
      instance.swagger_helper_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#spec_swagger_path" do
    let(:expected_path) { "spec/swagger/.gitkeep" }

    def perform
      instance.spec_swagger_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#spec_integration_path" do
    let(:expected_path) { "spec/integration/.gitkeep" }

    def perform
      instance.spec_integration_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_resource_schema_path" do
    let(:expected_path) { "spec/swagger/v1/schemas/blog_schema.rb" }

    def perform
      instance.swagger_resource_schema_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_version_definition_path" do
    let(:expected_path) { "spec/swagger/v1/definition.rb" }

    def perform
      instance.swagger_version_definition_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_resource_spec_path" do
    let(:expected_path) { "spec/integration/api/v1/blogs_spec.rb" }

    def perform
      instance.swagger_resource_spec_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_helper_api_definition_line" do
    let(:expected_path) do
      "config.swagger_docs = {\n"
    end

    def perform
      instance.swagger_helper_api_definition_line
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#swagger_definition_line_to_inject_schema" do
    let(:expected_line) { /definitions: {/ }

    def perform
      instance.swagger_definition_line_to_inject_schema
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
      instance.swagger_helper_api_definition
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

  describe "swagger_helper_tpl" do
    let(:template) do
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

    def perform
      instance.swagger_helper_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "#get_swagger_schema_tpl" do
    let(:template) do
      <<~SCHEMA
        BLOG_SCHEMA = {
          type: :object,
          properties: {
            id: { type: :string, example: '1' },
            type: { type: :string, example: 'blog' },
            attributes: {
              type: :object,
              properties: {
                title: { type: :string, example: 'Some title' },
                body: { type: :string, example: 'Some body' },
                created_at: { type: :string, example: '1984-06-04 09:00' },
                updated_at: { type: :string, example: '1984-06-04 09:00' }
              },
              required: [
                :title,
                :body,
                :created_at,
                :updated_at
              ]
            }
          },
          required: [
            :id,
            :type,
            :attributes
          ]
        }

        BLOGS_COLLECTION_SCHEMA = {
          type: "object",
          properties: {
            data: {
              type: "array",
              items: { "$ref" => "#/definitions/blogs_collection" }
            }
          },
          required: [
            :data
          ]
        }

        BLOG_RESOURCE_SCHEMA = {
          type: "object",
          properties: {
            data: { "$ref" => "#/definitions/blog_resource" }
          },
          required: [
            :data
          ]
        }
      SCHEMA
    end

    def perform
      instance.get_swagger_schema_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "#swagger_definition_entry" do
    let(:expected_entry) do
      "\n    blog: BLOG_SCHEMA,\
\n    blogs_collection: BLOGS_COLLECTION_SCHEMA,\
\n    blog_resource: BLOG_RESOURCE_SCHEMA,"
    end

    def perform
      instance.swagger_definition_entry
    end

    it { expect(perform).to eq(expected_entry) }
  end
end
