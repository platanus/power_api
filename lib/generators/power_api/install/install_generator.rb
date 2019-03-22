class PowerApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_api_base_controller
    template "api_base_controller.rb", "app/controllers/api/base_controller.rb"
  end

  def create_ams_initializer
    template "ams_initializer.rb", "config/initializers/active_model_serializers.rb"
  end

  def install_rswag
    generate "rswag:ui:install"
    generate "rswag:api:install"
    generate "rswag:specs:install"
  end

  def install_first_version
    generate "power_api:create_version 1"
  end
end
