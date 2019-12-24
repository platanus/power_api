describe PowerApi::AmsHelper do
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
      include ::PowerApi::AmsHelper

      def initialize(config)
        self.version_number = config[:version_number]
        self.resource_name = config[:resource_name]
        self.resource_attributes = config[:resource_attributes]
      end
    end
  end

  before { create_test_class(&class_definition) }

  describe "#ams_initializer_path" do
    let(:expected_path) { "config/initializers/active_model_serializers.rb" }

    def perform
      instance.ams_initializer_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#serializers_path" do
    let(:expected_path) do
      "app/serializers/api/v1/.gitkeep"
    end

    def perform
      subject.serializers_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_path) do
        "app/serializers/api/v2/.gitkeep"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#ams_serializer_path" do
    let(:expected_path) { "app/serializers/api/v1/blog_serializer.rb" }

    def perform
      instance.ams_serializer_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "ams_initializer_tpl" do
    let(:template) do
      <<~INITIALIZER
        class ActiveModelSerializers::Adapter::JsonApi
          def self.default_key_transform
            :unaltered
          end
        end

        ActiveModelSerializers.config.adapter = :json_api
      INITIALIZER
    end

    def perform
      instance.ams_initializer_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "generate_serializer_tpl" do
    let(:template) do
      <<~SERIALIZER
        class Api::V1::BlogSerializer < ActiveModel::Serializer
          type :blog

          attributes :title, :body, :created_at, :updated_at
        end
      SERIALIZER
    end

    def perform
      instance.generate_serializer_tpl
    end

    it { expect(perform).to eq(template) }
  end
end
