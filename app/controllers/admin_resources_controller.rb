require "net/http"
require "json"

class AdminResourcesController < ApplicationController
  before_action :require_valid_admin!

  RESOURCE_CONFIG = {
    "profile" => {
      title: "Profile",
      endpoint: "/api/v1/admin/profile",
      summary: "Kelola identitas utama, headline, bio, dan kontak portfolio."
    },
    "projects" => {
      title: "Projects",
      endpoint: "/api/v1/admin/projects",
      summary: "Daftar project portfolio yang tampil di website publik."
    },
    "skills" => {
      title: "Skills",
      endpoint: "/api/v1/admin/skills",
      summary: "Teknologi dan kemampuan utama yang ingin ditampilkan."
    },
    "experiences" => {
      title: "Experiences",
      endpoint: "/api/v1/admin/experiences",
      summary: "Riwayat pengalaman kerja atau proyek profesional."
    },
    "social_links" => {
      title: "Social Links",
      endpoint: "/api/v1/admin/social-links",
      summary: "Link sosial dan platform publik yang terhubung ke profil."
    },
    "media" => {
      title: "Media",
      endpoint: nil,
      summary: "Placeholder untuk modul galeri/files. Endpoint media belum dibuat di backend."
    }
  }.freeze

  def show
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]

    unless @resource
      redirect_to dashboard_path, alert: "Menu tidak ditemukan."
      return
    end

    @data = fetch_resource_data(@resource)
    render template_for_resource
  end

  def update_profile
    @resource_key = "profile"
    @resource = RESOURCE_CONFIG[@resource_key]
    response = submit_profile(profile_params)

    if response[:status] == :ok
      redirect_to admin_resource_path("profile"), notice: response[:message]
    else
      @data = fetch_resource_data(@resource)
      @form_values = profile_params.to_h
      flash.now[:alert] = response[:message]
      render :profile, status: :unprocessable_entity
    end
  end

  def create_project
    prepare_project_form
    response = submit_project(:post, @resource[:endpoint], project_params.to_h)

    if response[:status] == :ok
      render json: { message: response[:message] }, status: :created
    else
      render json: { message: response[:message] }, status: :unprocessable_entity
    end
  end

  def update_project
    prepare_project_form
    response = submit_project(:patch, "#{@resource[:endpoint]}/#{params[:id]}", project_params.to_h)

    if response[:status] == :ok
      render json: { message: response[:message] }, status: :ok
    else
      render json: { message: response[:message] }, status: :unprocessable_entity
    end
  end

  def destroy_project
    prepare_project_form
    response = delete_resource("#{@resource[:endpoint]}/#{params[:id]}")

    if response[:status] == :ok
      render json: { message: response[:message] }, status: :ok
    else
      render json: { message: response[:message] }, status: :unprocessable_entity
    end
  end

  def create_skill
    @resource_key = "skills"
    @resource = RESOURCE_CONFIG[@resource_key]
    response = submit_skill(:post, @resource[:endpoint], skill_params)

    if response[:status] == :ok
      render json: { message: response[:message] }, status: :created
    else
      render json: { message: response[:message] }, status: :unprocessable_entity
    end
  end

  def update_skill
    @resource_key = "skills"
    @resource = RESOURCE_CONFIG[@resource_key]
    response = submit_skill(:patch, "#{@resource[:endpoint]}/#{params[:id]}", skill_params)

    if response[:status] == :ok
      render json: { message: response[:message] }, status: :ok
    else
      render json: { message: response[:message] }, status: :unprocessable_entity
    end
  end

  def destroy_skill
    @resource_key = "skills"
    @resource = RESOURCE_CONFIG[@resource_key]
    response = delete_resource("#{@resource[:endpoint]}/#{params[:id]}")

    if response[:status] == :ok
      render json: { message: response[:message] }, status: :ok
    else
      render json: { message: response[:message] }, status: :unprocessable_entity
    end
  end


  private

  def profile_template?
    @resource_key == "profile"
  end

  def datatable_template?
    %w[projects skills experiences].include?(@resource_key)
  end

  def template_for_resource
    return :profile if profile_template?
    return :datatable if datatable_template?

    :show
  end

  def fetch_resource_data(resource)
    return { status: :pending, items: [], raw: nil, message: "Modul ini belum punya endpoint backend." } if resource[:endpoint].blank?

    uri = URI.parse("#{backend_base_url}#{resource[:endpoint]}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{admin_token}"

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    payload = safe_json(response.body)

    if response.code.to_i == 200
      data = payload["data"]
      items = data.is_a?(Array) ? data : (data.present? ? [data] : [])
      { status: :ok, items: items, raw: data, message: payload["message"].presence || "Data loaded." }
    else
      { status: :error, items: [], raw: payload, message: payload["message"].presence || "Gagal mengambil data dari backend." }
    end
  rescue StandardError => e
    { status: :error, items: [], raw: nil, message: "Gagal terhubung ke backend: #{e.message}" }
  end

  def submit_profile(payload)
    uri = URI.parse("#{backend_base_url}#{@resource[:endpoint]}")
    request = Net::HTTP::Put.new(uri)
    request["Authorization"] = "Bearer #{admin_token}"
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    parsed = safe_json(response.body)

    if response.code.to_i == 200
      { status: :ok, message: parsed["message"].presence || "Profile updated." }
    else
      { status: :error, message: parsed["message"].presence || "Gagal menyimpan profile." }
    end
  rescue StandardError => e
    { status: :error, message: "Gagal terhubung ke backend: #{e.message}" }
  end

  def prepare_project_form
    @resource_key = "projects"
    @resource = RESOURCE_CONFIG[@resource_key]
  end


  def default_project_form_values
    {
      "title" => "",
      "slug" => "",
      "summary" => "",
      "description" => "",
      "thumbnail_path" => "",
      "project_url" => "",
      "repo_url" => "",
      "is_featured" => false,
      "sort_order" => 0
    }
  end

  def fetch_project(id)
    uri = URI.parse("#{backend_base_url}#{@resource[:endpoint]}/#{id}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{admin_token}"

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    payload = safe_json(response.body)
    response.code.to_i == 200 ? payload["data"] : nil
  rescue StandardError
    nil
  end

  def submit_project(method, path, payload)
    uri = URI.parse("#{backend_base_url}#{path}")
    request = build_json_request(method, uri, payload)
    response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
    parsed = safe_json(response.body)

    if response.code.to_i.between?(200, 299)
      { status: :ok, message: parsed["message"].presence || "Project saved." }
    else
      { status: :error, message: parsed["message"].presence || "Gagal menyimpan project." }
    end
  rescue StandardError => e
    { status: :error, message: "Gagal terhubung ke backend: #{e.message}" }
  end

  def delete_resource(path)
    uri = URI.parse("#{backend_base_url}#{path}")
    request = Net::HTTP::Delete.new(uri)
    request["Authorization"] = "Bearer #{admin_token}"
    response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
    parsed = safe_json(response.body)

    if response.code.to_i.between?(200, 299)
      { status: :ok, message: parsed["message"].presence || "Data deleted." }
    else
      { status: :error, message: parsed["message"].presence || "Gagal menghapus data." }
    end
  rescue StandardError => e
    { status: :error, message: "Gagal terhubung ke backend: #{e.message}" }
  end

  def build_json_request(method, uri, payload)
    request_class = case method.to_sym
                    when :post then Net::HTTP::Post
                    when :patch then Net::HTTP::Put
                    else Net::HTTP::Post
                    end
    request = request_class.new(uri)
    request["Authorization"] = "Bearer #{admin_token}"
    request["Content-Type"] = "application/json"
    request.body = payload.to_json
    request
  end

  def project_params
    permitted = params.require(:project).permit(:title, :slug, :summary, :description, :thumbnail_path, :project_url, :repo_url, :sort_order, :is_featured).to_h
    permitted["is_featured"] = ActiveModel::Type::Boolean.new.cast(permitted["is_featured"])
    permitted["sort_order"] = permitted["sort_order"].to_i
    permitted
  end

  def submit_skill(method, path, payload)
    uri = URI.parse("#{backend_base_url}#{path}")
    request = build_json_request(method, uri, payload)
    response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
    parsed = safe_json(response.body)

    if response.code.to_i.between?(200, 299)
      { status: :ok, message: parsed["message"].presence || "Skill saved." }
    else
      { status: :error, message: parsed["message"].presence || "Gagal menyimpan skill." }
    end
  rescue StandardError => e
    { status: :error, message: "Gagal terhubung ke backend: #{e.message}" }
  end

  def skill_params
    permitted = params.require(:skill).permit(:name, :level, :icon_path, :sort_order).to_h
    permitted["sort_order"] = permitted["sort_order"].to_i
    permitted
  end

  def profile_params
    params.require(:profile).permit(:full_name, :headline, :sub_headline, :bio, :email, :phone, :location, :avatar_path, :resume_path)
  end

  def safe_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    {}
  end
end
