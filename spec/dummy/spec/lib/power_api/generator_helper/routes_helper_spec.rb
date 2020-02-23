RSpec.describe PowerApi::GeneratorHelper::RoutesHelper, type: :generator do
  describe "#routes_path" do
    let(:expected_path) { "config/routes.rb" }

    def perform
      generators_helper.routes_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#routes_line_to_inject_resource" do
    let(:expected_line) { /Api::V1[^\n]*/ }

    def perform
      generators_helper.routes_line_to_inject_resource
    end

    it { expect(perform).to eq(expected_line) }
  end

  describe "#resource_route_tpl" do
    let(:expected_tpl) { "\nresources :blogs" }

    def perform
      generators_helper.resource_route_tpl
    end

    it { expect(perform).to eq(expected_tpl) }
  end

  describe "routes_line_to_inject_new_version" do
    let(:expected_line) do
      "routes.draw do\n"
    end

    def perform
      generators_helper.routes_line_to_inject_new_version
    end

    it { expect(perform).to eq(expected_line) }

    context "when is not the first version" do
      let(:version_number) { "2" }

      let(:expected_line) do
        "'/api' do\n"
      end

      it { expect(perform).to eq(expected_line) }
    end
  end

  describe "#version_route_tpl" do
    let(:expected_tpl) do
      <<~ROUTE
        scope path: '/api' do
        api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
        end
        end
      ROUTE
    end

    def perform
      generators_helper.version_route_tpl
    end

    it { expect(perform).to eq(expected_tpl) }

    context "when is not the first version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<~ROUTE
          api_version(module: 'Api::V2', path: { value: 'v2' }, defaults: { format: 'json' }) do
          end
        ROUTE
      end

      it { expect(perform).to eq(expected_tpl.delete_suffix("\n")) }
    end
  end
end
