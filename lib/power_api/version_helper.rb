module PowerApi
  module VersionHelper
    def version_number
      raise NotImplementedError.new("version_number not implemented")
    end

    def validate_version_number!(version_number)
      version = version_number.to_s.to_i
      raise GeneratorError.new("invalid version number") if version < 1

      true
    end
  end
end
