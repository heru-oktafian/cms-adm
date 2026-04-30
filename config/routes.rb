Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/login", to: "sessions#new", as: :login
  post "/admin/login", to: "sessions#create", as: :admin_login
  delete "/logout", to: "sessions#destroy", as: :logout

  get "/dashboard", to: "dashboard#index", as: :dashboard
  get "/admin/:resource", to: "admin_resources#show", as: :admin_resource
  patch "/admin/profile", to: "admin_resources#update_profile", as: :update_admin_profile
  post "/admin/projects", to: "admin_resources#create_project", as: :create_admin_project
  patch "/admin/projects/:id", to: "admin_resources#update_project", as: :update_admin_project
  delete "/admin/projects/:id", to: "admin_resources#destroy_project", as: :destroy_admin_project

  root "sessions#new"
end
