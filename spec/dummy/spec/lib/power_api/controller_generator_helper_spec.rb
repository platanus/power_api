require "rails_helper"

describe PowerApi::ControllerGeneratorHelper do
  subject { described_class.new(init_params) }

  let(:version_number) { "1" }
  let(:resource_name) { "blog" }
  let(:init_params) do
    {
      version_number: version_number,
      resource_name: resource_name
    }
  end

  describe "generate_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::V1::BlogsController < Api::V1::BaseController
          def index
            respond_with Blog.all
          end

          def show
            respond_with blog
          end

          def create
            respond_with Blog.create!(blog_params)
          end

          def update
            respond_with blog.update!(blog_params)
          end

          def destroy
            blog.destroy!
          end

          private

          def blog
            @blog ||= Blog.find_by!(id: params[:id])
          end

          def blog_params
            params.require(:blog).permit(
              :title, :body, :created_at, :updated_at
            )
          end
        end
      CONTROLLER
    end

    def perform
      subject.generate_controller_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "#get_controller_path" do
    let(:expected_path) { "app/controllers/api/v1/blogs_controller.rb" }

    def perform
      subject.get_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#routes_line_to_inject_resource" do
    let(:expected_line) { /Api::V1[^\n]*/ }

    def perform
      subject.routes_line_to_inject_resource
    end

    it { expect(perform).to eq(expected_line) }
  end

  describe "#resource_route_template" do
    let(:expected_tpl) {   "\n      resources :blogs" }

    def perform
      subject.resource_route_template
    end

    it { expect(perform).to eq(expected_tpl) }
  end

  describe "#get_serializer_path" do
    let(:expected_path) { "app/serializers/api/v1/blog_serializer.rb" }

    def perform
      subject.get_serializer_path
    end

    it { expect(perform).to eq(expected_path) }
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
      subject.generate_serializer_tpl
    end

    it { expect(perform).to eq(template) }
  end
end
