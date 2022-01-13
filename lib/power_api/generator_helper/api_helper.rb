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

  def api_file_path
    return version_file_path if versioned_api?

    internal_file_path
  end

  def version_file_path
    "#{exposed_file_path}/v#{version_number}"
  end

  def internal_file_path
    "api/internal"
  end

  def exposed_file_path
    "api/exposed"
  end

  def api_class
    return version_class if versioned_api?

    internal_class
  end

  def version_class
    "#{exposed_class}::V#{version_number}"
  end

  def internal_class
    "Api::Internal"
  end

  def exposed_class
    "Api::Exposed"
  end
end
