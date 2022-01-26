describe PowerApi::GeneratorHelper::RspecControllerHelper, type: :generator do
  describe "#resource_spec_path" do
    let(:expected_path) { "spec/requests/api/exposed/v1/blogs_spec.rb" }

    def perform
      generators_helper.resource_spec_path
    end

    it { expect(perform).to eq(expected_path) }

    context "when nil version" do
      let(:version_number) { nil }
      let(:expected_path) { "spec/requests/api/internal/blogs_spec.rb" }

      it { expect(perform).to eq(expected_path) }
    end
  end

  describe "#resource_spec_tpl" do
    let(:template) do
      <<~SPEC
        require 'rails_helper'

        RSpec.describe 'Api::Exposed::V1::BlogsControllers', type: :request do
        describe 'GET /index' do
        let!(:blogs) { create_list(:blog, 5) }
        let(:collection) { JSON.parse(response.body)['blogs'] }
        let(:params) { {} }

        def perform
        get '/api/v1/blogs', params: params
        end

        before do
        perform
        end

        it { expect(collection.count).to eq(5) }
        it { expect(response.status).to eq(200) }
        end

        describe 'POST /create' do
        let(:params) do
        {
        blog: {
        title: 'Some title',
        body: 'Some body'
        }
        }
        end

        let(:attributes) do
        JSON.parse(response.body)['blog'].symbolize_keys
        end
        def perform
        post '/api/v1/blogs', params: params
        end

        before do
        perform
        end

        it { expect(attributes).to include(params[:blog]) }
        it { expect(response.status).to eq(201) }
        context 'with invalid attributes' do
        let(:params) do
        {
        blog: {
        title: nil}
        }
        end

        it { expect(response.status).to eq(400) }
        end

        end

        describe 'GET /show' do
        let(:blog) { create(:blog) }
        let(:blog_id) { blog.id.to_s }

        let(:attributes) do
        JSON.parse(response.body)['blog'].symbolize_keys
        end
        def perform
        get '/api/v1/blogs/' + blog_id
        end

        before do
        perform
        end

        it { expect(response.status).to eq(200) }
        context 'with resource not found' do
        let(:blog_id) { '666' }
        it { expect(response.status).to eq(404) }
        end
        end

        describe 'PUT /update' do
        let(:blog) { create(:blog) }
        let(:blog_id) { blog.id.to_s }

        let(:params) do
        {
        blog: {
        title: 'Some title',
        body: 'Some body'
        }
        }
        end

        let(:attributes) do
        JSON.parse(response.body)['blog'].symbolize_keys
        end
        def perform
        put '/api/v1/blogs/' + blog_id, params: params
        end

        before do
        perform
        end

        it { expect(attributes).to include(params[:blog]) }
        it { expect(response.status).to eq(200) }
        context 'with invalid attributes' do
        let(:params) do
        {
        blog: {
        title: nil}
        }
        end

        it { expect(response.status).to eq(400) }
        end

        context 'with resource not found' do
        let(:blog_id) { '666' }
        it { expect(response.status).to eq(404) }
        end
        end

        describe 'DELETE /destroy' do
        let(:blog) { create(:blog) }
        let(:blog_id) { blog.id.to_s }

        def perform
        get '/api/v1/blogs/' + blog_id
        end

        before do
        perform
        end

        it { expect(response.status).to eq(200) }
        context 'with resource not found' do
        let(:blog_id) { '666' }
        it { expect(response.status).to eq(404) }
        end
        end

        end
      SPEC
    end

    def perform
      generators_helper.resource_spec_tpl
    end

    it { expect(perform).to eq(template) }

    context "when nil version" do
      let(:version_number) { nil }

      it { expect(perform).to include("RSpec.describe 'Api::Internal::BlogsControllers'") }
      it { expect(perform).to include("get '/api/internal/blogs', params: params") }
    end

    context "with authenticated_resource option" do
      let(:authenticated_resource) { "user" }

      let(:template) do
        <<~SPEC
          require 'rails_helper'

          RSpec.describe 'Api::Exposed::V1::BlogsControllers', type: :request do
          let(:user) { create(:user) }
          describe 'GET /index' do
          let!(:blogs) { create_list(:blog, 5) }
          let(:collection) { JSON.parse(response.body)['blogs'] }
          let(:params) { {} }

          def perform
          get '/api/v1/blogs', params: params
          end

          context 'with authorized user' do
          before do
          sign_in(user)
          perform
          end

          it { expect(collection.count).to eq(5) }
          it { expect(response.status).to eq(200) }
          end

          context 'with unauthenticated user' do
          before { perform }

          it { expect(response.status).to eq(401) }
          end

          end

          describe 'POST /create' do
          let(:params) do
          {
          blog: {
          title: 'Some title',
          body: 'Some body'
          }
          }
          end

          let(:attributes) do
          JSON.parse(response.body)['blog'].symbolize_keys
          end
          def perform
          post '/api/v1/blogs', params: params
          end

          context 'with authorized user' do
          before do
          sign_in(user)
          perform
          end

          it { expect(attributes).to include(params[:blog]) }
          it { expect(response.status).to eq(201) }
          context 'with invalid attributes' do
          let(:params) do
          {
          blog: {
          title: nil}
          }
          end

          it { expect(response.status).to eq(400) }
          end

          end

          context 'with unauthenticated user' do
          before { perform }

          it { expect(response.status).to eq(401) }
          end

          end

          describe 'GET /show' do
          let(:blog) { create(:blog) }
          let(:blog_id) { blog.id.to_s }

          let(:attributes) do
          JSON.parse(response.body)['blog'].symbolize_keys
          end
          def perform
          get '/api/v1/blogs/' + blog_id
          end

          context 'with authorized user' do
          before do
          sign_in(user)
          perform
          end

          it { expect(response.status).to eq(200) }
          context 'with resource not found' do
          let(:blog_id) { '666' }
          it { expect(response.status).to eq(404) }
          end
          end

          context 'with unauthenticated user' do
          before { perform }

          it { expect(response.status).to eq(401) }
          end

          end

          describe 'PUT /update' do
          let(:blog) { create(:blog) }
          let(:blog_id) { blog.id.to_s }

          let(:params) do
          {
          blog: {
          title: 'Some title',
          body: 'Some body'
          }
          }
          end

          let(:attributes) do
          JSON.parse(response.body)['blog'].symbolize_keys
          end
          def perform
          put '/api/v1/blogs/' + blog_id, params: params
          end

          context 'with authorized user' do
          before do
          sign_in(user)
          perform
          end

          it { expect(attributes).to include(params[:blog]) }
          it { expect(response.status).to eq(200) }
          context 'with invalid attributes' do
          let(:params) do
          {
          blog: {
          title: nil}
          }
          end

          it { expect(response.status).to eq(400) }
          end

          context 'with resource not found' do
          let(:blog_id) { '666' }
          it { expect(response.status).to eq(404) }
          end
          end

          context 'with unauthenticated user' do
          before { perform }

          it { expect(response.status).to eq(401) }
          end

          end

          describe 'DELETE /destroy' do
          let(:blog) { create(:blog) }
          let(:blog_id) { blog.id.to_s }

          def perform
          get '/api/v1/blogs/' + blog_id
          end

          context 'with authorized user' do
          before do
          sign_in(user)
          perform
          end

          it { expect(response.status).to eq(200) }
          context 'with resource not found' do
          let(:blog_id) { '666' }
          it { expect(response.status).to eq(404) }
          end
          end

          context 'with unauthenticated user' do
          before { perform }

          it { expect(response.status).to eq(401) }
          end

          end

          end
        SPEC
      end

      it { expect(perform).to eq(template) }

      context "with owned_by_authenticated_resource option" do
        let(:authenticated_resource) { "user" }
        let(:owned_by_authenticated_resource) { true }

        it { expect(perform).to include("create_list(:blog, 5, user: user)") }
      end
    end

    context "with parent_resource option" do
      let(:parent_resource_name) { "portfolio" }

      let(:template) do
        <<~SPEC
          require 'rails_helper'

          RSpec.describe 'Api::Exposed::V1::BlogsControllers', type: :request do
          let(:portfolio) { create(:portfolio) }
          let(:portfolio_id) { portfolio.id }

          describe 'GET /index' do
          let!(:blogs) { create_list(:blog, 5, portfolio: portfolio) }
          let(:collection) { JSON.parse(response.body)['blogs'] }
          let(:params) { {} }

          def perform
          get '/api/v1/portfolios/' + portfolio.id.to_s + '/blogs', params: params
          end

          before do
          perform
          end

          it { expect(collection.count).to eq(5) }
          it { expect(response.status).to eq(200) }
          end

          describe 'POST /create' do
          let(:params) do
          {
          blog: {
          title: 'Some title',
          body: 'Some body'
          }
          }
          end

          let(:attributes) do
          JSON.parse(response.body)['blog'].symbolize_keys
          end
          def perform
          post '/api/v1/portfolios/' + portfolio.id.to_s + '/blogs', params: params
          end

          before do
          perform
          end

          it { expect(attributes).to include(params[:blog]) }
          it { expect(response.status).to eq(201) }
          context 'with invalid attributes' do
          let(:params) do
          {
          blog: {
          title: nil}
          }
          end

          it { expect(response.status).to eq(400) }
          end

          end

          describe 'GET /show' do
          let(:blog) { create(:blog, portfolio: portfolio) }
          let(:blog_id) { blog.id.to_s }

          let(:attributes) do
          JSON.parse(response.body)['blog'].symbolize_keys
          end
          def perform
          get '/api/v1/blogs/' + blog_id
          end

          before do
          perform
          end

          it { expect(response.status).to eq(200) }
          context 'with resource not found' do
          let(:blog_id) { '666' }
          it { expect(response.status).to eq(404) }
          end
          end

          describe 'PUT /update' do
          let(:blog) { create(:blog, portfolio: portfolio) }
          let(:blog_id) { blog.id.to_s }

          let(:params) do
          {
          blog: {
          title: 'Some title',
          body: 'Some body'
          }
          }
          end

          let(:attributes) do
          JSON.parse(response.body)['blog'].symbolize_keys
          end
          def perform
          put '/api/v1/blogs/' + blog_id, params: params
          end

          before do
          perform
          end

          it { expect(attributes).to include(params[:blog]) }
          it { expect(response.status).to eq(200) }
          context 'with invalid attributes' do
          let(:params) do
          {
          blog: {
          title: nil}
          }
          end

          it { expect(response.status).to eq(400) }
          end

          context 'with resource not found' do
          let(:blog_id) { '666' }
          it { expect(response.status).to eq(404) }
          end
          end

          describe 'DELETE /destroy' do
          let(:blog) { create(:blog, portfolio: portfolio) }
          let(:blog_id) { blog.id.to_s }

          def perform
          get '/api/v1/blogs/' + blog_id
          end

          before do
          perform
          end

          it { expect(response.status).to eq(200) }
          context 'with resource not found' do
          let(:blog_id) { '666' }
          it { expect(response.status).to eq(404) }
          end
          end

          end
        SPEC
      end

      it { expect(perform).to eq(template) }
    end

    context 'with only some actions (show and create)' do
      let(:controller_actions) do
        [
          "show",
          "create"
        ]
      end

      it { expect(perform).to include("describe 'GET /show'") }
      it { expect(perform).to include("describe 'POST /create'") }
      it { expect(perform).not_to include("describe 'DELETE /destroy'") }
      it { expect(perform).not_to include("describe 'PUT /update'") }
      it { expect(perform).not_to include("describe 'GET /index'") }
    end
  end
end
