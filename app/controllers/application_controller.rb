require "net/http"
require "json"

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :admin_logged_in?

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

    uri = URI.parse("#{backend_base_url}/api/v1/admin/auth/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{token}"

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    Rails.logger.info("[auth-debug] /auth/me response=#{response.code}")
    response.code.to_i == 200
  rescue StandardError => e
    Rails.logger.error("[auth-debug] validate_admin_token! error=#{e.class}: #{e.message}")
    false
  end

  def require_valid_admin!
    unless validate_admin_token!
      clear_admin_cookie
      redirect_to login_path, alert: "Session expired. Please login again."
    end
  end

  def clear_admin_cookie
    cookies.delete(:admin_token)
  end
end
