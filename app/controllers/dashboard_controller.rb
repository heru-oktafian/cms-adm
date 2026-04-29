class DashboardController < ApplicationController
  before_action :require_valid_admin!

  def index; end
end
