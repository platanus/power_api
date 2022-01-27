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
      "app/serializers/api/exposed/v1/.gitkeep"
    end

    def perform
      subject.ams_serializers_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_path) do
        "app/serializers/api/exposed/v2/.gitkeep"
      end

      it { expect(perform).to eq(expected_path) }
    end

    context "with no version" do
      let(:version_number) { "" }

      let(:expected_path) do
        "app/serializers/api/internal/.gitkeep"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#ams_serializer_path" do
    let(:expected_path) { "app/serializers/api/exposed/v1/blog_serializer.rb" }

    def perform
      generators_helper.ams_serializer_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with no version" do
      let(:version_number) { nil }

      let(:expected_path) do
        "app/serializers/api/internal/blog_serializer.rb"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "ams_initializer_tpl" do
    let(:template) do
      <<~INITIALIZER
        ActiveModelSerializers.config.adapter = :json
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
        class Api::Exposed::V1::BlogSerializer < ActiveModel::Serializer
          type :blog

          attributes(
            :id,
        :title,
        :body,
        :created_at,
        :updated_at,
        :portfolio_id
        )
        end
      SERIALIZER
    end

    def perform
      generators_helper.ams_serializer_tpl
    end

    it { expect(perform).to eq(template) }

    context "with no version" do
      let(:version_number) { nil }

      let(:template) do
        <<~SERIALIZER
          class Api::Internal::BlogSerializer < ActiveModel::Serializer
            type :blog

            attributes(
              :id,
          :title,
          :body,
          :created_at,
          :updated_at,
          :portfolio_id
          )
          end
        SERIALIZER
      end

      it { expect(perform).to eq(template) }
    end
  end
end
