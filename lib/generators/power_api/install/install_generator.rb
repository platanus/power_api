class PowerApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_api_base_controller
    create_file(helper.api_main_base_controller_path, helper.api_main_base_controller_tpl)
  end

  def create_ams_initializer
    create_file(helper.ams_initializer_path, helper.ams_initializer_tpl)
  end

  def install_api_pagination
    create_file(
      helper.api_pagination_initializer_path,
      helper.api_pagination_initializer_tpl,
      force: true
    )
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new
  end
end
