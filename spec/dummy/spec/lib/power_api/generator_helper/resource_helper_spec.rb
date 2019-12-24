# rubocop:disable Metrics/LineLength
RSpec.describe PowerApi::GeneratorHelper::ResourceHelper, type: :generator do
  describe "#resource_name" do
    def perform
      generators_helper.resource_name
    end

    it { expect(perform).to eq("blog") }
  end

  describe "#upcase_resource" do
    def perform
      generators_helper.upcase_resource
    end

    it { expect(perform).to eq("BLOG") }
  end

  describe "#upcase_plural_resource" do
    def perform
      generators_helper.upcase_plural_resource
    end

    it { expect(perform).to eq("BLOGS") }
  end

  describe "#resource_name=" do
    context "with invalid resource name" do
      let(:resource_name) { "ticket" }

      it { expect { generators_helper }.to raise_error(/Invalid resource name/) }
    end

    context "with missing resource name" do
      let(:resource_name) { "" }

      it { expect { generators_helper }.to raise_error(/Invalid resource name/) }
    end

    context "when resource is not an active record model" do
      let(:resource_name) { "power_api" }

      it { expect { generators_helper }.to raise_error("resource is not an active record model") }
    end
  end

  describe "#resource_attributes" do
    let(:expected_attributes) do
      [
        { name: :title, type: :string, swagger_type: :string, example: "'Some title'", required: true },
        { name: :body, type: :text, swagger_type: :string, example: "'Some body'", required: true },
        { name: :created_at, type: :datetime, swagger_type: :string, example: "'1984-06-04 09:00'", required: false },
        { name: :updated_at, type: :datetime, swagger_type: :string, example: "'1984-06-04 09:00'", required: false }
      ]
    end

    def perform
      generators_helper.resource_attributes
    end

    it { expect(perform).to eq(expected_attributes) }

    context "with selected attributes" do
      let(:resource_attributes) { %w{title body} }
      let(:expected_attributes) do
        [
          { name: :title, type: :string, swagger_type: :string, example: "'Some title'", required: true },
          { name: :body, type: :text, swagger_type: :string, example: "'Some body'", required: true }
        ]
      end

      it { expect(perform).to eq(expected_attributes) }
    end

    context "with attributes not present in model" do
      let(:resource_attributes) { %w{title bloody} }
      let(:expected_attributes) do
        [
          { name: :title, type: :string, swagger_type: :string, example: "'Some title'", required: true }
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
      generators_helper.resource_attributes_names
    end

    it { expect(perform).to eq(expected_attributes) }
  end

  describe "#resource_attributes_symbols_text_list" do
    let(:expected_result) do
      ":title, :body, :created_at, :updated_at"
    end

    def perform
      generators_helper.resource_attributes_symbols_text_list
    end

    it { expect(perform).to eq(expected_result) }
  end

  describe "#resource_attributes=" do
    context "with provided attributes resulting in empty attributes config" do
      let(:resource_attributes) { %w{invalid attrs} }

      it { expect { generators_helper }.to raise_error("at least one attribute must be added") }
    end
  end

  describe "#camel_resource" do
    def perform
      generators_helper.camel_resource
    end

    it { expect(perform).to eq("Blog") }
  end

  describe "#plural_resource" do
    def perform
      generators_helper.plural_resource
    end

    it { expect(perform).to eq("blogs") }
  end

  describe "#snake_case_resource" do
    def perform
      generators_helper.snake_case_resource
    end

    it { expect(perform).to eq("blog") }
  end
end
# rubocop:enable Metrics/LineLength
