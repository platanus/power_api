module PowerApi
  class Engine < ::Rails::Engine
    isolate_namespace PowerApi

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    initializer "initialize" do
      require_relative "./controller_generator_helper"
    end
  end
end
