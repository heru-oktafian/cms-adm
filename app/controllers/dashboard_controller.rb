class DashboardController < ApplicationController
  before_action :require_valid_admin!

  MENU_ITEMS = [
    { key: "dashboard", label: "Dashboard", path_helper: :dashboard_path },
    { key: "profile", label: "Profile", path: "/admin/profile" },
    { key: "skills", label: "Skills", path: "/admin/skills" },
    { key: "tools", label: "Tools", path: "/admin/tools" },
    { key: "projects", label: "Projects", path: "/admin/projects" },
    { key: "experiences", label: "Experiences", path: "/admin/experiences" },
    { key: "social_links", label: "Social Links", path: "/admin/social_links" },
    { key: "messages", label: "Messages", path: "/admin/messages" }
  ].freeze

  helper_method :navigation_items, :dashboard_stats

  def index
    @stats = dashboard_stats
  end

  private

  def navigation_items
    MENU_ITEMS.map do |item|
      item.merge(path: item[:path] || send(item[:path_helper]))
    end
  end

  def dashboard_stats
    counts = backend_get_json("/api/v1/admin/counts")
    return default_stats if counts.nil?
    {
      skills: counts["skills"] || 0,
      projects: counts["projects"] || 0,
      experiences: counts["experiences"] || 0,
      messages: counts["messages"] || 0
    }
  rescue
    default_stats
  end

  def default_stats
    { skills: 0, projects: 0, experiences: 0, messages: 0 }
  end
end
