describe PowerApi::ResourceHelper do
  subject(:resourceable) { TestClass.new(resource_name, resource_attributes) }

  let(:resource_name) { "blog" }
  let(:resource_attributes) { nil }
  let(:class_definition) do
    Proc.new do
      include ::PowerApi::ResourceHelper

      def initialize(resource_name, resource_attributes)
        self.resource_name = resource_name
        self.resource_attributes = resource_attributes
      end
    end
  end

  before { create_test_class(&class_definition) }

  describe "#resource_name" do
    def perform
      resourceable.resource_name
    end

    it { expect(perform).to eq("blog") }
  end

  describe "#upcase_resource" do
    def perform
      resourceable.upcase_resource
    end

    it { expect(perform).to eq("BLOG") }
  end

  describe "#upcase_plural_resource" do
    def perform
      resourceable.upcase_plural_resource
    end

    it { expect(perform).to eq("BLOGS") }
  end

  describe "#resource_name=" do
    context "with invalid resource name" do
      let(:resource_name) { "ticket" }

      it { expect { resourceable }.to raise_error(/Invalid resource name/) }
    end

    context "with missing resource name" do
      let(:resource_name) { "" }

      it { expect { resourceable }.to raise_error(/Invalid resource name/) }
    end

    context "when resource is not an active record model" do
      let(:resource_name) { "power_api" }

      it { expect { resourceable }.to raise_error("resource is not an active record model") }
    end
  end

  describe "#resource_attributes" do
    let(:expected_attributes) do
      [
        { name: :title, type: :string, swagger_type: :string, example: "'Some title'" },
        { name: :body, type: :text, swagger_type: :string, example: "'Some body'" },
        { name: :created_at, type: :datetime, swagger_type: :string, example: "'1984-06-04 09:00'" },
        { name: :updated_at, type: :datetime, swagger_type: :string, example: "'1984-06-04 09:00'" }
      ]
    end

    def perform
      resourceable.resource_attributes
    end

    it { expect(perform).to eq(expected_attributes) }

    context "with selected attributes" do
      let(:resource_attributes) { %w{title body} }
      let(:expected_attributes) do
        [
          { name: :title, type: :string, swagger_type: :string, example: "'Some title'" },
          { name: :body, type: :text, swagger_type: :string, example: "'Some body'" }
        ]
      end

      it { expect(perform).to eq(expected_attributes) }
    end

    context "with attributes not present in model" do
      let(:resource_attributes) { %w{title bloody} }
      let(:expected_attributes) do
        [
          { name: :title, type: :string, swagger_type: :string, example: "'Some title'" }
        ]
      end

      it { expect(perform).to eq(expected_attributes) }
    end
  end

  describe "#resource_attributes_names" do
    let(:expected_attributes) do
      [
        :title,
        :body,
        :created_at,
        :updated_at
      ]
    end

    def perform
      resourceable.resource_attributes_names
    end

    it { expect(perform).to eq(expected_attributes) }
  end

  describe "#resource_attributes_symbols_text_list" do
    let(:expected_result) do
      ":title, :body, :created_at, :updated_at"
    end

    def perform
      resourceable.resource_attributes_symbols_text_list
    end

    it { expect(perform).to eq(expected_result) }
  end

  describe "#resource_attributes=" do
    context "with provided attributes resulting in empty attributes config" do
      let(:resource_attributes) { %w{invalid attrs} }

      it { expect { resourceable }.to raise_error("at least one attribute must be added") }
    end
  end

  describe "#camel_resource" do
    def perform
      resourceable.camel_resource
    end

    it { expect(perform).to eq("Blog") }
  end

  describe "#plural_resource" do
    def perform
      resourceable.plural_resource
    end

    it { expect(perform).to eq("blogs") }
  end

  describe "#snake_case_resource" do
    def perform
      resourceable.snake_case_resource
    end

    it { expect(perform).to eq("blog") }
  end
end
