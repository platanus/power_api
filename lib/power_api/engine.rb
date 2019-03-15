module PowerApi
  class Engine < ::Rails::Engine
    isolate_namespace PowerApi

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    initializer "initialize" do
      # Require here all your engine's classes.
      require_relative "./example_class"
    end
  end
end
