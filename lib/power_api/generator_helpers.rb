module PowerApi
  class GeneratorHelpers
    include GeneratorHelper::ControllerActionsHelper
    include GeneratorHelper::ResourceHelper
    include GeneratorHelper::ApiHelper
    include GeneratorHelper::RspecControllerHelper
    include GeneratorHelper::AmsHelper
    include GeneratorHelper::ControllerHelper
    include GeneratorHelper::RoutesHelper
    include GeneratorHelper::PaginationHelper
    include GeneratorHelper::SimpleTokenAuthHelper
    include GeneratorHelper::RubocopHelper

    def initialize(config = {})
      config.each do |attribute, value|
        load_attribute(attribute, value)
      end
    end

    private

    def load_attribute(attribute, value)
      send("#{attribute}=", value)
    end
  end
end
