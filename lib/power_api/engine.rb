module PowerApi
  module GeneratorHelper; end

  class Engine < ::Rails::Engine
    isolate_namespace PowerApi

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    initializer "initialize" do
      require_relative "./errors"
      require_relative "./generator_helper/version_helper"
      require_relative "./generator_helper/resource_helper"
      require_relative "./generator_helper/swagger_helper"
      require_relative "./generator_helper/ams_helper"
      require_relative "./generator_helper/controller_helper"
      require_relative "./generator_helper/routes_helper"
      require_relative "./generator_helper/pagination_helper"
      require_relative "./generator_helpers"
    end
  end
end
