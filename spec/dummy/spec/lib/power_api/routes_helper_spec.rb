describe PowerApi::RoutesHelper do
  subject(:instance) { TestClass.new(init_params) }

  let(:version_number) { "1" }
  let(:resource_name) { "blog" }

  let(:init_params) do
    {
      version_number: version_number,
      resource_name: resource_name
    }
  end

  let(:class_definition) do
    Proc.new do
      include ::PowerApi::RoutesHelper

      def initialize(config)
        self.version_number = config[:version_number]
        self.resource_name = config[:resource_name]
      end
    end
  end

  before { create_test_class(&class_definition) }

  describe "#routes_line_to_inject_resource" do
    let(:expected_line) { /Api::V1[^\n]*/ }

    def perform
      instance.routes_line_to_inject_resource
    end

    it { expect(perform).to eq(expected_line) }
  end

  describe "#resource_route_template" do
    let(:expected_tpl) { "\n      resources :blogs" }

    def perform
      instance.resource_route_template
    end

    it { expect(perform).to eq(expected_tpl) }
  end

  describe "routes_line_to_inject_new_version" do
    let(:expected_line) do
      "routes.draw do\n"
    end

    def perform
      instance.routes_line_to_inject_new_version
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

  describe "#version_route_template" do
    let(:expected_tpl) do
      <<-ROUTE
  scope path: '/api' do
    api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
    end
  end
      ROUTE
    end

    def perform
      instance.version_route_template
    end

    it { expect(perform).to eq(expected_tpl) }

    context "when is not the first version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<-ROUTE
    api_version(module: 'Api::V2', path: { value: 'v2' }, defaults: { format: 'json' }) do
    end

        ROUTE
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end
end
