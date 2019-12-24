module PowerApi
  class VersionGeneratorHelper
    include VersionHelper
    include SwaggerHelper
    include AmsHelper
    include ControllerHelper
    include RoutesHelper

    def initialize(config)
      self.version_number = config[:version_number]
    end
  end
end
