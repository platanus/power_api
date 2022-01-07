module PowerApi::GeneratorHelper::ApiHelper
  extend ActiveSupport::Concern

  included do
    attr_reader :version_number
  end

  def version_number=(value)
    @version_number = value.to_s.to_i
    raise PowerApi::GeneratorError.new("invalid version number") if version_number < 1
  end

  def first_version?
    version_number.to_i == 1
  end
end
