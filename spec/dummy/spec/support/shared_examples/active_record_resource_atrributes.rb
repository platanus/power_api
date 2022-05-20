# rubocop:disable Metrics/LineLength
shared_examples 'ActiveRecord resource attributes' do |attributes_key|
  describe "#resource_attributes" do
    let(:expected_attributes) do
      [
        { name: :id, type: :integer, example: kind_of(Integer), required: false },
        { name: :title, type: :string, example: "'Some title'", required: true },
        { name: :body, type: :text, example: "'Some body'", required: true },
        { name: :created_at, type: :datetime, example: "'1984-06-04 09:00'", required: false },
        { name: :updated_at, type: :datetime, example: "'1984-06-04 09:00'", required: false },
        { name: :portfolio_id, type: :integer, example: kind_of(Integer), required: false }
      ]
    end

    def perform
      resource.resource_attributes
    end

    it { expect(perform).to match(expected_attributes) }

    context "with selected attributes" do
      let(attributes_key) { %w{title body} }
      let(:expected_attributes) do
        [
          { name: :id, type: :integer, example: kind_of(Integer), required: false },
          { name: :title, type: :string, example: "'Some title'", required: true },
          { name: :body, type: :text, example: "'Some body'", required: true }
        ]
      end

      it { expect(perform).to match(expected_attributes) }
    end

    context "with attributes not present in model" do
      let(attributes_key) { %w{title bloody} }
      let(:expected_attributes) do
        [
          { name: :id, type: :integer, example: kind_of(Integer), required: false },
          { name: :title, type: :string, example: "'Some title'", required: true }
        ]
      end

      it { expect(perform).to match(expected_attributes) }
    end
  end

  describe "#required_resource_attributes" do
    let(:include_id) { false }
    let(:expected_attributes) do
      [
        { name: :title, type: :string, example: "'Some title'", required: true },
        { name: :body, type: :text, example: "'Some body'", required: true }
      ]
    end

    def perform
      resource.required_resource_attributes(include_id: include_id)
    end

    it { expect(perform).to eq(expected_attributes) }

    context "with included id" do
      let(:include_id) { true }
      let(:expected_attributes) do
        [
          { name: :id, type: :integer, example: kind_of(Integer), required: false },
          { name: :title, type: :string, example: "'Some title'", required: true },
          { name: :body, type: :text, example: "'Some body'", required: true }
        ]
      end

      it { expect(perform).to match(expected_attributes) }
    end
  end

  describe "#required_attributes_names" do
    let(:expected_attributes) do
      [
        :title,
        :body
      ]
    end

    def perform
      resource.required_attributes_names
    end

    it { expect(perform).to eq(expected_attributes) }
  end

  describe "#optional_resource_attributes" do
    let(:expected_attributes) do
      [
        { name: :portfolio_id, type: :integer, example: kind_of(Integer), required: false }
      ]
    end

    def perform
      resource.optional_resource_attributes
    end

    it { expect(perform).to match(expected_attributes) }
  end

  describe "#attributes_names" do
    let(:expected_attributes) do
      [
        :id,
        :title,
        :body,
        :created_at,
        :updated_at,
        :portfolio_id
      ]
    end

    def perform
      resource.attributes_names
    end

    it { expect(perform).to eq(expected_attributes) }
  end

  describe "#permitted_attributes" do
    let(:expected_attributes) do
      [
        { name: :title, type: :string, example: "'Some title'", required: true },
        { name: :body, type: :text, example: "'Some body'", required: true },
        { name: :portfolio_id, type: :integer, example: kind_of(Integer), required: false }
      ]
    end

    def perform
      resource.permitted_attributes
    end

    it { expect(perform).to match(expected_attributes) }
  end

  describe "#permitted_attributes_names" do
    let(:expected_attributes) do
      [
        :title,
        :body,
        :portfolio_id
      ]
    end

    def perform
      resource.permitted_attributes_names
    end

    it { expect(perform).to eq(expected_attributes) }
  end

  describe "#attributes_symbols_text_list" do
    let(:expected_result) do
      <<~ATTRS
        :id,
        :title,
        :body,
        :created_at,
        :updated_at,
        :portfolio_id
      ATTRS
    end

    def perform
      resource.attributes_symbols_text_list
    end

    it { expect(perform).to eq(expected_result) }
  end

  describe "#resource_attributes=" do
    context "with provided attributes resulting in empty attributes config" do
      let(attributes_key) { %w{invalid attrs} }

      it { expect { generators_helper }.to raise_error("at least one attribute must be added") }
    end
  end
end
# rubocop:enable Metrics/LineLength
