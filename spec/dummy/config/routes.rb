Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :internal do
      resources :blogs
    end
  end
end
