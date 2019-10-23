Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  scope path: '/api' do
    api_version(module: 'Api::V2', path: { value: 'v2' }, defaults: { format: 'json' }) do
    end

    api_version(module: 'Api::V1', path: { value: 'v1' }, defaults: { format: 'json' }) do
      resources :blogs
    end
  end
end
