module PowerApi
  class Engine < ::Rails::Engine
    isolate_namespace PowerApi

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    initializer "initialize" do
      require_relative "./errors"
      require_relative "./version_helper"
      require_relative "./resource_helper"
      require_relative "./swagger_helper"
      require_relative "./ams_helper"
      require_relative "./install_generator_helper"
      require_relative "./version_generator_helper"
      require_relative "./controller_generator_helper"
    end
  end
end
