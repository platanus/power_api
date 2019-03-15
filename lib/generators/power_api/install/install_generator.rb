class PowerApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_api_base_controller
    template "api_base_controller.rb", "app/controllers/api/base_controller.rb"
  end
end
