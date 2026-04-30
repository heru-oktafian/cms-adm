require "net/http"
require "json"

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :admin_logged_in?, :navigation_items, :active_nav_key

  private

  def backend_base_url
    ENV.fetch("CMS_BE_BASE_URL", "http://127.0.0.1:8080")
  end

  def admin_token
    cookies.encrypted[:admin_token]
  end

  def admin_logged_in?
    admin_token.present?
  end

  def validate_admin_token!
    token = admin_token
    Rails.logger.info("[auth-debug] cookie token present=#{token.present?} length=#{token.to_s.length}")
    return false if token.blank?

    cache_key = token_validation_cache_key(token)
    cached = session[cache_key]

    if cached.present? && cached["valid_until"].to_i > Time.now.to_i
      Rails.logger.info("[auth-debug] /auth/me skipped using short session cache")
      return true
    end

    uri = URI.parse("#{backend_base_url}/api/v1/admin/auth/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{token}"

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    Rails.logger.info("[auth-debug] /auth/me response=#{response.code}")

    if response.code.to_i == 200
      session[cache_key] = { "valid_until" => 10.minutes.from_now.to_i }
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error("[auth-debug] validate_admin_token! error=#{e.class}: #{e.message}")
    false
  end

  def require_valid_admin!
    unless validate_admin_token!
      clear_admin_cookie
      respond_to do |format|
        format.html { redirect_to login_path, alert: "Session expired. Please login again." }
        format.json { render json: { message: "Session expired. Please login again." }, status: :unauthorized }
      end
    end
  end

  def clear_admin_cookie
    cookies.delete(:admin_token)
    session.to_hash.keys.grep(/^admin_token_valid_/).each { |key| session.delete(key) }
  end

  def token_validation_cache_key(token)
    "admin_token_valid_#{Digest::SHA256.hexdigest(token.to_s)[0, 16]}"
  end

  def navigation_items
    DashboardController::MENU_ITEMS.map do |item|
      item.merge(path: item[:path] || send(item[:path_helper]))
    end
  end

  def active_nav_key
    return "dashboard" if request.path == dashboard_path

    resource = params[:resource].presence
    resource&.to_s
  end
end
