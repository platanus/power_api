Rails.application.routes.draw do
  mount PowerApi::Engine => "/power_api"
end
