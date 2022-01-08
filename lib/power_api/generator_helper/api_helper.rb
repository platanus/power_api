module PowerApi::GeneratorHelper::ApiHelper
  extend ActiveSupport::Concern

  included do
    attr_reader :version_number
  end

  def version_number=(value)
    if value.blank?
      @version_number = nil
      return
    end

    @version_number = value.to_s.to_i
    raise PowerApi::GeneratorError.new("invalid version number") if version_number < 1
  end

  def first_version?
    version_number.to_i == 1
  end

  def versioned_api?
    !!version_number
  end

  def api_file_path_prefix
    return "api/exposed/v#{version_number}" if versioned_api?

    "api/internal"
  end

  def api_class_prefix
    return "Api::Exposed::V#{version_number}" if versioned_api?

    "Api::Internal"
  end
end
