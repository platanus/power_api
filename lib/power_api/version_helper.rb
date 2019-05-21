module PowerApi
  module VersionHelper
    def version_number
      raise "Not implemented"
    end

    def validate_version_number!(version_number)
      version = version_number.to_s.to_i
      fail "invalid version number" if version < 1

      true
    end
  end
end
