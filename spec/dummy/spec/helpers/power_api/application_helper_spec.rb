require "spec_helper"

describe PowerApi::ApplicationHelper do
  describe "#serialize_resource" do
    let(:resource) do
      build(
        :blog,
        id: 1,
        title: "T",
        portfolio_id: 2,
        body: "B",
        created_at: "2022-01-28T20:30:00.000Z",
        updated_at: "2022-01-28T20:40:00.000Z"
      )
    end

    let(:options) { {} }

    def data
      helper.serialize_resource(resource, options)
    end

    let(:expected_serialized_data) do
      <<~DATA.strip
        {\"id\":1,\"title\":\"T\",\"body\":\"B\",\"createdAt\":\"2022-01-28T20:30:00.000Z\",\"updatedAt\":\"2022-01-28T20:40:00.000Z\",\"portfolioId\":2}
      DATA
    end

    it { expect(data).to eq(expected_serialized_data) }

    context "with fields option" do
      let(:options) do
        {
          fields: [:id, :body]
        }
      end

      let(:expected_serialized_data) do
        <<~DATA.strip
          {\"id\":1,\"body\":\"B\"}
        DATA
      end

      it { expect(data).to eq(expected_serialized_data) }
    end

    context "with key_transform option" do
      let(:options) do
        {
          key_transform: :unaltered
        }
      end

      let(:expected_serialized_data) do
        <<~DATA.strip
          {\"id\":1,\"title\":\"T\",\"body\":\"B\",\"created_at\":\"2022-01-28T20:30:00.000Z\",\"updated_at\":\"2022-01-28T20:40:00.000Z\",\"portfolio_id\":2}
        DATA
      end

      it { expect(data).to eq(expected_serialized_data) }
    end

    context "with include_root option" do
      let(:options) do
        {
          include_root: true
        }
      end

      let(:expected_serialized_data) do
        <<~DATA.strip
          {"blog":{"id":1,"title":"T","body":"B","createdAt":"2022-01-28T20:30:00.000Z","updatedAt":"2022-01-28T20:40:00.000Z","portfolioId":2}}
        DATA
      end

      it { expect(data).to eq(expected_serialized_data) }
    end

    context "with collection resource" do
      let(:options) do
        {
          include_root: false,
          fields: [:body]
        }
      end

      let(:resource) do
        create_list(:blog, 2)
      end

      let(:expected_serialized_data) do
        <<~DATA.strip
          [{\"body\":\"MyText\"},{\"body\":\"MyText\"}]
        DATA
      end

      it { expect(data).to eq(expected_serialized_data) }
    end

    context "with invalid resource" do
      let(:resource) do
        { invalid: "resource" }
      end

      it { expect { data }.to raise_error(PowerApi::InvalidSerializableResource, /Invalid Hash/) }
    end

    context "with hash output" do
      let(:options) do
        {
          output: :hash
        }
      end

      let(:expected_serialized_data) do
        {
          body: "B",
          created_at: "2022-01-28 20:30:00.000000000 +0000",
          id: 1,
          portfolio_id: 2,
          title: "T",
          updated_at: "2022-01-28 20:40:00.000000000 +0000"
        }
      end

      it { expect(data).to eq(expected_serialized_data) }

      context "with key_transform option" do
        before { options[:key_transform] = :camel_lower }

        it { expect(data).to eq(expected_serialized_data) }
      end
    end

    context "with invalid output option" do
      let(:options) do
        { output: "invalid" }
      end

      it { expect { data }.to raise_error(PowerApi::InvalidSerializerOutput, /:json, :hash/) }
    end

    context "with meta option" do
      let(:options) do
        {
          meta: { hola: "platanus" }
        }
      end

      let(:expected_serialized_data) do
        <<~DATA.strip
          {\"id\":1,\"title\":\"T\",\"body\":\"B\",\"createdAt\":\"2022-01-28T20:30:00.000Z\",\"updatedAt\":\"2022-01-28T20:40:00.000Z\",\"portfolioId\":2}
        DATA
      end

      it { expect(data).to eq(expected_serialized_data) }

      context "with include_root option" do
        before { options[:include_root] = true }

        let(:expected_serialized_data) do
          <<~DATA.strip
            {\"blog\":{\"id\":1,\"title\":\"T\",\"body\":\"B\",\"createdAt\":\"2022-01-28T20:30:00.000Z\",\"updatedAt\":\"2022-01-28T20:40:00.000Z\",\"portfolioId\":2},\"meta\":{\"hola\":\"platanus\"}}
          DATA
        end

        it { expect(data).to eq(expected_serialized_data) }
      end
    end
  end
end
