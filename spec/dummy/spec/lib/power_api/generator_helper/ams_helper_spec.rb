RSpec.describe PowerApi::GeneratorHelper::AmsHelper, type: :generator do
  describe "#ams_initializer_path" do
    let(:expected_path) { "config/initializers/active_model_serializers.rb" }

    def perform
      generators_helper.ams_initializer_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#ams_serializers_path" do
    let(:expected_path) do
      "app/serializers/api/v1/.gitkeep"
    end

    def perform
      subject.ams_serializers_path
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
      generators_helper.ams_serializer_path
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
      generators_helper.ams_initializer_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "ams_serializer_tpl" do
    let(:template) do
      <<~SERIALIZER
        class Api::V1::BlogSerializer < ActiveModel::Serializer
          type :blog

          attributes :title, :body, :created_at, :updated_at
        end
      SERIALIZER
    end

    def perform
      generators_helper.ams_serializer_tpl
    end

    it { expect(perform).to eq(template) }
  end
end
