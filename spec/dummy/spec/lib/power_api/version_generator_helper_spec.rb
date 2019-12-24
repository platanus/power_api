require "rails_helper"

describe PowerApi::VersionGeneratorHelper do
  subject { described_class.new(init_params) }

  let(:version_number) { "1" }
  let(:init_params) do
    {
      version_number: version_number
    }
  end

  describe "routes_line_to_inject_new_version" do
    let(:expected_line) do
      "routes.draw do\n"
    end

    def perform
      subject.routes_line_to_inject_new_version
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
      subject.version_route_template
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

  describe "#base_controller_path" do
    let(:expected_path) do
      "app/controllers/api/v1/base_controller.rb"
    end

    def perform
      subject.base_controller_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_path) do
        "app/controllers/api/v2/base_controller.rb"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#base_controller_template" do
    let(:expected_tpl) do
      <<~CONTROLLER
        class Api::V1::BaseController < Api::BaseController
          before_action do
            self.namespace_for_serializer = ::Api::V1
          end
        end
      CONTROLLER
    end

    def perform
      subject.base_controller_template
    end

    it { expect(perform).to eq(expected_tpl) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<~CONTROLLER
          class Api::V2::BaseController < Api::BaseController
            before_action do
              self.namespace_for_serializer = ::Api::V2
            end
          end
        CONTROLLER
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end
end
