class DashboardController < ApplicationController
  before_action :require_valid_admin!

  MENU_ITEMS = [
    { key: "dashboard", label: "Dashboard", path_helper: :dashboard_path },
    { key: "profile", label: "Profile", path: "/admin/profile" },
    { key: "projects", label: "Projects", path: "/admin/projects" },
    { key: "skills", label: "Skills", path: "/admin/skills" },
    { key: "experiences", label: "Experiences", path: "/admin/experiences" },
    { key: "social_links", label: "Social Links", path: "/admin/social_links" },
    { key: "media", label: "Media", path: "/admin/media" }
  ].freeze

  helper_method :navigation_items

  def index; end

  private

  def navigation_items
    MENU_ITEMS.map do |item|
      item.merge(path: item[:path] || send(item[:path_helper]))
    end
  end
end
