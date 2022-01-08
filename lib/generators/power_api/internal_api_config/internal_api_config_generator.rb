class PowerApi::InternalApiConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def add_base_controller
    create_file(
      helper.internal_base_controller_path,
      helper.internal_base_controller_tpl
    )
  end

  def add_serializers_directory
    create_file(helper.ams_serializers_path)
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new
  end
end
