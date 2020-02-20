module PowerApi
  class GeneratorHelpers
    include GeneratorHelper::ResourceHelper
    include GeneratorHelper::VersionHelper
    include GeneratorHelper::SwaggerHelper
    include GeneratorHelper::AmsHelper
    include GeneratorHelper::ControllerHelper
    include GeneratorHelper::RoutesHelper
    include GeneratorHelper::PaginationHelper
    include GeneratorHelper::SimpleTokenAuthHelper
    include GeneratorHelper::RubocopHelper

    def initialize(config = {})
      validate_config(config)

      config.each do |attribute, value|
        load_attribute(attribute, value)
      end
    end

    private

    def validate_config(config)
      if config[:owned_by_authenticated_resource].present? &&
          config[:authenticated_resource].blank?
        raise PowerApi::GeneratorError.new(
          "you need to provide --authenticate-with before setting \
--owned-by-authenticated-resource option"
        )
      end
    end

    def load_attribute(attribute, value)
      send("#{attribute}=", value)
    end
  end
end
