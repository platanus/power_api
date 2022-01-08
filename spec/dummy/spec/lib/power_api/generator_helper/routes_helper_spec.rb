RSpec.describe PowerApi::GeneratorHelper::RoutesHelper, type: :generator do
  describe "#routes_path" do
    let(:expected_path) { "config/routes.rb" }

    def perform
      generators_helper.routes_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#api_version_routes_line_regex" do
    let(:expected_regex) { /Api::Exposed::V1[^\n]*/ }

    def perform
      generators_helper.api_version_routes_line_regex
    end

    it { expect(perform).to eq(expected_regex) }
  end

  describe "#parent_resource_routes_line_regex" do
    def perform
      generators_helper.parent_resource_routes_line_regex
    end

    it { expect { perform }.to raise_error("missing parent_resource") }

    context "with parent_resource" do
      let(:expected_regex) { /resources :users[^\n]*/ }
      let(:parent_resource_name) { "user" }

      it { expect(perform).to eq(expected_regex) }
    end
  end

  describe "#resource_route_tpl" do
    let(:actions) { [] }
    let(:expected_tpl) { "resources :blogs" }
    let(:parent_resource_name) { "user" }
    let(:is_parent) { false }

    def perform
      generators_helper.resource_route_tpl(actions: actions, is_parent: is_parent)
    end

    it { expect(perform).to eq(expected_tpl) }

    context "with specific actions" do
      let(:actions) { ["index", "create"] }
      let(:expected_tpl) { "resources :blogs, only: [:index, :create]" }

      it { expect(perform).to eq(expected_tpl) }
    end

    context "with is_parent option actions" do
      let(:is_parent) { true }
      let(:expected_tpl) { "resources :users" }

      it { expect(perform).to eq(expected_tpl) }
    end
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
        api_version(module: 'Api::Exposed::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
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
          api_version(module: 'Api::Exposed::V2', path: { value: 'v2' }, defaults: { format: 'json' }) do
          end
        ROUTE
      end

      it { expect(perform).to eq(expected_tpl.delete_suffix("\n")) }
    end
  end

  describe "#internal_route_tpl" do
    let(:expected_tpl) do
      <<~ROUTE
        namespace :api do
        namespace :internal do
        end
        end
      ROUTE
    end

    def perform
      generators_helper.internal_route_tpl
    end

    it { expect(perform).to eq(expected_tpl) }
  end

  describe "#parent_route_exist?" do
    let(:parent_resource_name) { "user" }
    let(:line) { nil }

    def perform
      generators_helper.parent_route_exist?
    end

    before { mock_file_content("config/routes.rb", [line]) }

    context "with file line not matching regex" do
      let(:line) { "X" }

      it { expect(perform).to eq(false) }
    end

    context "with no parent_resource" do
      let(:parent_resource_name) { nil }

      it { expect { perform }.to raise_error("missing parent_resource") }
    end

    context "with file line matching regex" do
      let(:line) { "resources :users" }

      it { expect(perform).to eq(true) }
    end
  end

  describe "#parent_route_already_have_children?" do
    let(:parent_resource_name) { "user" }
    let(:line) { nil }

    def perform
      generators_helper.parent_route_already_have_children?
    end

    before { mock_file_content("config/routes.rb", [line]) }

    context "with file line not matching regex" do
      let(:line) { "X" }

      it { expect(perform).to eq(false) }
    end

    context "with no parent_resource" do
      let(:parent_resource_name) { nil }

      it { expect { perform }.to raise_error("missing parent_resource") }
    end

    context "with parent line found but with no children" do
      let(:line) { "resources :users" }

      it { expect(perform).to eq(false) }
    end

    context "with parent line found with children" do
      let(:line) { "resources :users do" }

      it { expect(perform).to eq(true) }
    end
  end
end
