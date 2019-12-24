RSpec.describe PowerApi::GeneratorHelper::ControllerHelper, type: :generator do
  describe "#api_base_controller_path" do
    let(:expected_path) { "app/controllers/api/base_controller.rb" }

    def perform
      generators_helper.api_base_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#resource_controller_path" do
    let(:expected_path) { "app/controllers/api/v1/blogs_controller.rb" }

    def perform
      generators_helper.resource_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "api_base_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::BaseController < PowerApi::BaseController
        end
      CONTROLLER
    end

    def perform
      generators_helper.api_base_controller_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "#base_controller_path" do
    let(:expected_path) do
      "app/controllers/api/v1/base_controller.rb"
    end

    def perform
      generators_helper.base_controller_path
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

  describe "resource_controller_tpl" do
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
              :title, :body
            )
          end
        end
      CONTROLLER
    end

    def perform
      generators_helper.resource_controller_tpl
    end

    it { expect(perform).to eq(template) }

    context "with specific attributes" do
      let(:resource_attributes) do
        [
          "title",
          "created_at"
        ]
      end

      let(:expected) do
        ":title"
      end

      it { expect(perform).to include(expected) }
    end

    context "with true use_paginator option" do
      let(:use_paginator) { true }
      let(:expected) do
        "respond_with paginate(Blog.all)"
      end

      it { expect(perform).to include(expected) }
    end

    context "with true allow_filters option" do
      let(:allow_filters) { true }
      let(:expected) do
        "respond_with filtered_collection(Blog.all)"
      end

      it { expect(perform).to include(expected) }
    end

    context "with true allow_filters and use_paginator options" do
      let(:allow_filters) { true }
      let(:use_paginator) { true }
      let(:expected) do
        "respond_with paginate(filtered_collection(Blog.all))"
      end

      it { expect(perform).to include(expected) }
    end
  end

  describe "#base_controller_tpl" do
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
      generators_helper.base_controller_tpl
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
