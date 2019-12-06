module Api::Versioned
  extend ActiveSupport::Concern

  DEFAULT_API_VERSIONS = 1

  included do
    before_action :check_api_version!
    after_action :add_version_to_content_type
  end

  private

  def available_api_versions
    ENV.fetch("AVAILABLE_API_VERSIONS", DEFAULT_API_VERSIONS)
  end

  def check_api_version!
    return if (1..available_api_versions) === version_number

    raise ::PowerApi::InvalidVersion.new("invalid API version")
  end

  def version_number
    @version_number ||= begin
      v = request.headers["Accept"].to_s.match(/version=(\d+)/)&.captures&.first.to_i
      v.zero? ? DEFAULT_API_VERSIONS : v
    end
  end

  def add_version_to_content_type
    content_type_header = response.headers["Content-Type"]
    parts = !content_type_header ? [] : content_type_header.to_s.split(";").map(&:strip)
    parts << "version=#{@version_number}"
    response.headers["Content-Type"] = parts.join("; ")
  end
end
