require "net/http"
require "json"

class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if validate_admin_token!
  end

  def create
    response = login_to_backend(email: params[:email], password: params[:password])

    if response.code.to_i == 200
      payload = JSON.parse(response.body)
      token = payload.dig("data", "token")

      Rails.logger.info("[auth-debug] login success token present=#{token.present?} length=#{token.to_s.length}")

      cookies.encrypted[:admin_token] = {
        value: token,
        httponly: true,
        same_site: :lax
      }

      Rails.logger.info("[auth-debug] encrypted cookie written")
      redirect_to dashboard_path, notice: "Login berhasil."
    else
      payload = safe_json(response.body)
      Rails.logger.warn("[auth-debug] login failed backend_status=#{response.code} message=#{payload['message']}")
      flash.now[:alert] = payload["message"].presence || "Login gagal."
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("[auth-debug] create error=#{e.class}: #{e.message}")
    flash.now[:alert] = "Gagal terhubung ke backend: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def destroy
    clear_admin_cookie
    redirect_to login_path, notice: "Logout berhasil."
  end

  private

  def login_to_backend(email:, password:)
    uri = URI.parse("#{backend_base_url}/api/v1/admin/auth/login")
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = { email: email.to_s.strip, password: password.to_s.strip }.to_json

    Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end
  end

  def safe_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    {}
  end
end
