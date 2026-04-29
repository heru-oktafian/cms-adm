Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/login", to: "sessions#new", as: :login
  post "/admin/login", to: "sessions#create", as: :admin_login
  delete "/logout", to: "sessions#destroy", as: :logout

  get "/dashboard", to: "dashboard#index", as: :dashboard

  root "sessions#new"
end
