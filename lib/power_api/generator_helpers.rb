module PowerApi
  class GeneratorHelpers
    include GeneratorHelper::ResourceHelper
    include GeneratorHelper::VersionHelper
    include GeneratorHelper::SwaggerHelper
    include GeneratorHelper::AmsHelper
    include GeneratorHelper::ControllerHelper
    include GeneratorHelper::RoutesHelper
    include GeneratorHelper::PaginationHelper

    def initialize(config = {})
      config.each do |attribute, value|
        load_attribute(attribute, value)
      end
    end

    private

    def load_attribute(attribute, value)
      self.send("#{attribute}=", value)
    end
  end
end
