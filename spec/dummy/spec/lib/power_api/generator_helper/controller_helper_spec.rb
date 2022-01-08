RSpec.describe PowerApi::GeneratorHelper::ControllerHelper, type: :generator do
  describe "#api_main_base_controller_path" do
    let(:expected_path) { "app/controllers/api/base_controller.rb" }

    def perform
      generators_helper.api_main_base_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#exposed_base_controller_path" do
    let(:expected_path) { "app/controllers/api/exposed/base_controller.rb" }

    def perform
      generators_helper.exposed_base_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#internal_base_controller_path" do
    let(:expected_path) { "app/controllers/api/internal/base_controller.rb" }

    def perform
      generators_helper.internal_base_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#version_base_controller_path" do
    let(:expected_path) { "app/controllers/api/exposed/v1/base_controller.rb" }

    def perform
      generators_helper.version_base_controller_path
    end

    it { expect(perform).to eq(expected_path) }
  end

  describe "#resource_controller_path" do
    let(:expected_path) { "app/controllers/api/exposed/v1/blogs_controller.rb" }

    def perform
      generators_helper.resource_controller_path
    end

    it { expect(perform).to eq(expected_path) }

    context "without version" do
      let(:version_number) { "" }
      let(:expected_path) { "app/controllers/api/internal/blogs_controller.rb" }

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#version_base_controller_path" do
    let(:expected_path) do
      "app/controllers/api/exposed/v1/base_controller.rb"
    end

    def perform
      generators_helper.version_base_controller_path
    end

    it { expect(perform).to eq(expected_path) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_path) do
        "app/controllers/api/exposed/v2/base_controller.rb"
      end

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "api_main_base_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::BaseController < PowerApi::BaseController
        end
      CONTROLLER
    end

    def perform
      generators_helper.api_main_base_controller_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "exposed_base_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::Exposed::BaseController < Api::BaseController
        end
      CONTROLLER
    end

    def perform
      generators_helper.exposed_base_controller_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "internal_base_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::Internal::BaseController < Api::BaseController
          before_action do
            self.namespace_for_serializer = ::Api::Internal
          end
        end
      CONTROLLER
    end

    def perform
      generators_helper.internal_base_controller_tpl
    end

    it { expect(perform).to eq(template) }
  end

  describe "resource_controller_tpl" do
    let(:template) do
      <<~CONTROLLER
        class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
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
        respond_with blog.destroy!
        end
        private
        def blog
        @blog ||= Blog.find_by!(id: params[:id])
        end
        def blog_params
        params.require(:blog).permit(
        :title,
        :body,
        :portfolio_id
        )
        end
        end
      CONTROLLER
    end

    def perform
      generators_helper.resource_controller_tpl
    end

    it { expect(perform).to eq(template) }

    context "without version" do
      let(:version_number) { nil }
      let(:expected) { "class Api::Internal::BlogsController < Api::Internal::BaseController" }

      it { expect(perform).to include(expected) }
    end

    context "with specific attributes" do
      let(:resource_attributes) do
        [
          "title",
          "created_at",
          "portfolio_id"
        ]
      end

      let(:expected) do
        ":title"
      end

      it { expect(perform).to include(expected) }
    end

    context 'with specific actions' do
      let(:controller_actions) do
        [
          "show",
          "update",
          "index"
        ]
      end

      it { expect(perform).to include("def show\n") }
      it { expect(perform).to include("def update\n") }
      it { expect(perform).to include("def index\n") }
      it { expect(perform).not_to include("def destroy\n") }
      it { expect(perform).not_to include("def create\n") }
    end

    context 'with only collection actions' do
      let(:controller_actions) do
        [
          "index",
          "create"
        ]
      end

      it { expect(perform).not_to include("def blog\n") }
    end

    context 'with some reource actions' do
      let(:controller_actions) do
        [
          "index",
          "create",
          "show"
        ]
      end

      it { expect(perform).to include("def blog\n") }
    end

    context 'with update action' do
      let(:controller_actions) { ["update"] }

      it { expect(perform).to include("def blog_params\n") }
    end

    context 'with create action' do
      let(:controller_actions) { ["create"] }

      it { expect(perform).to include("def blog_params\n") }
    end

    context 'without update or create actions' do
      let(:controller_actions) do
        [
          "index",
          "destroy",
          "show"
        ]
      end

      it { expect(perform).not_to include("def blog_params\n") }
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

    context "with authenticated_resource option" do
      let(:authenticated_resource) { "user" }
      let(:template) do
        <<~CONTROLLER
          class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
          acts_as_token_authentication_handler_for User, fallback: :exception

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
          respond_with blog.destroy!
          end
          private
          def blog
          @blog ||= Blog.find_by!(id: params[:id])
          end
          def blog_params
          params.require(:blog).permit(
          :title,
          :body,
          :portfolio_id
          )
          end
          end
        CONTROLLER
      end

      it { expect(perform).to eq(template) }
    end

    context "with owned_by_authenticated_resource and authenticated_resource" do
      let(:authenticated_resource) { "user" }
      let(:owned_by_authenticated_resource) { true }

      let(:template) do
        <<~CONTROLLER
          class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
          acts_as_token_authentication_handler_for User, fallback: :exception

          def index
          respond_with blogs
          end
          def show
          respond_with blog
          end
          def create
          respond_with blogs.create!(blog_params)
          end
          def update
          respond_with blog.update!(blog_params)
          end
          def destroy
          respond_with blog.destroy!
          end
          private
          def blog
          @blog ||= blogs.find_by!(id: params[:id])
          end
          def blogs
          @blogs ||= current_user.blogs
          end
          def blog_params
          params.require(:blog).permit(
          :title,
          :body,
          :portfolio_id
          )
          end
          end
        CONTROLLER
      end

      it { expect(perform).to eq(template) }
    end

    context "with owned_by_authenticated_resource but authenticated_resource" do
      let(:authenticated_resource) { nil }
      let(:owned_by_authenticated_resource) { true }

      it { expect(perform).to eq(template) }
    end

    context "with parent_resource option" do
      let(:parent_resource_name) { "portfolio" }
      let(:template) do
        <<~CONTROLLER
          class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
          def index
          respond_with blogs
          end
          def show
          respond_with blog
          end
          def create
          respond_with blogs.create!(blog_params)
          end
          def update
          respond_with blog.update!(blog_params)
          end
          def destroy
          respond_with blog.destroy!
          end
          private
          def blog
          @blog ||= Blog.find_by!(id: params[:id])
          end
          def blogs
          @blogs ||= portfolio.blogs
          end
          def portfolio
          @portfolio ||= Portfolio.find_by!(id: params[:portfolio_id])
          end
          def blog_params
          params.require(:blog).permit(
          :title,
          :body,
          :portfolio_id
          )
          end
          end
        CONTROLLER
      end

      it { expect(perform).to eq(template) }
    end

    context "with parent_resource owned by authenticated_resource" do
      let(:parent_resource_name) { "portfolio" }
      let(:authenticated_resource) { "user" }
      let(:owned_by_authenticated_resource) { true }
      let(:template) do
        <<~CONTROLLER
          class Api::Exposed::V1::BlogsController < Api::Exposed::V1::BaseController
          acts_as_token_authentication_handler_for User, fallback: :exception

          def index
          respond_with blogs
          end
          def show
          respond_with blog
          end
          def create
          respond_with blogs.create!(blog_params)
          end
          def update
          respond_with blog.update!(blog_params)
          end
          def destroy
          respond_with blog.destroy!
          end
          private
          def blog
          @blog ||= Blog.find_by!(id: params[:id])
          end
          def blogs
          @blogs ||= portfolio.blogs
          end
          def portfolio
          @portfolio ||= Portfolio.find_by!(id: params[:portfolio_id])
          end
          def blog_params
          params.require(:blog).permit(
          :title,
          :body,
          :portfolio_id
          )
          end
          end
        CONTROLLER
      end

      it { expect(perform).to eq(template) }
    end
  end

  describe "#version_base_controller_tpl" do
    let(:expected_tpl) do
      <<~CONTROLLER
        class Api::Exposed::V1::BaseController < Api::Exposed::BaseController
          before_action do
            self.namespace_for_serializer = ::Api::Exposed::V1
          end
        end
      CONTROLLER
    end

    def perform
      generators_helper.version_base_controller_tpl
    end

    it { expect(perform).to eq(expected_tpl) }

    context "with another version" do
      let(:version_number) { "2" }

      let(:expected_tpl) do
        <<~CONTROLLER
          class Api::Exposed::V2::BaseController < Api::Exposed::BaseController
            before_action do
              self.namespace_for_serializer = ::Api::Exposed::V2
            end
          end
        CONTROLLER
      end

      it { expect(perform).to eq(expected_tpl) }
    end
  end
end
