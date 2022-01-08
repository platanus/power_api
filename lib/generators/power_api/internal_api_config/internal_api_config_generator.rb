class PowerApi::InternalApiConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def add_base_controller
    create_file(
      helper.internal_base_controller_path,
      helper.internal_base_controller_tpl
    )
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new
  end
end
