module PowerApi
  class GeneratorHelpers
    include GeneratorHelper::ResourceHelper
    include GeneratorHelper::VersionHelper
    include GeneratorHelper::SwaggerHelper
    include GeneratorHelper::AmsHelper
    include GeneratorHelper::ControllerHelper
    include GeneratorHelper::RoutesHelper
    include GeneratorHelper::PaginationHelper

    def initialize(config)
      self.version_number = config[:version_number]
      self.resource_name = config[:resource_name]
      self.resource_attributes = config[:resource_attributes]
      self.use_paginator = config[:use_paginator]
      self.allow_filters = config[:allow_filters]
    end
  end
end
