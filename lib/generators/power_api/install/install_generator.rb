class PowerApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_api_base_controller
    create_file(helper.api_base_controller_path, helper.api_base_controller_tpl)
  end

  def create_ams_initializer
    create_file(helper.ams_initializer_path, helper.ams_initializer_tpl)
  end

  def install_rswag
    generate "rswag:ui:install"
    generate "rswag:api:install"
    generate "rswag:specs:install"

    create_file(helper.swagger_helper_path, helper.swagger_helper_tpl, force: true)
    create_file(helper.spec_swagger_path)
    create_file(helper.spec_integration_path)
  end

  def install_first_version
    generate "power_api:version 1"
  end

  def install_api_pagination
    create_file(helper.api_pagination_initializer_path, helper.api_pagination_initializer_tpl, force: true)
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new
  end
end
