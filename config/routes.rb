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
  post "/admin/skills", to: "admin_resources#create_skill", as: :create_admin_skill
  patch "/admin/skills/:id", to: "admin_resources#update_skill", as: :update_admin_skill
  delete "/admin/skills/:id", to: "admin_resources#destroy_skill", as: :destroy_admin_skill
  post "/admin/experiences", to: "admin_resources#create_experience", as: :create_admin_experience
  patch "/admin/experiences/:id", to: "admin_resources#update_experience", as: :update_admin_experience
  delete "/admin/experiences/:id", to: "admin_resources#destroy_experience", as: :destroy_admin_experience
  post "/admin/social-links", to: "admin_resources#create_social_link", as: :create_admin_social_link
  patch "/admin/social-links/:id", to: "admin_resources#update_social_link", as: :update_admin_social_link
  delete "/admin/social-links/:id", to: "admin_resources#destroy_social_link", as: :destroy_admin_social_link
  post "/admin/tools", to: "admin_resources#create_tool", as: :create_admin_tool
  patch "/admin/tools/:id", to: "admin_resources#update_tool", as: :update_admin_tool
  delete "/admin/tools/:id", to: "admin_resources#destroy_tool", as: :destroy_admin_tool

  root "sessions#new"
end
