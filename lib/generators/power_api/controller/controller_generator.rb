class PowerApi::ControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :version_number, type: :string, required: true

  def create_controller
    create_file(
      generator_helper.get_controller_path,
      generator_helper.generate_controller_tpl
    )
  end

  private

  def generator_helper
    PowerApi::ControllerGeneratorHelper.new(
      version_number: version_number,
      resource_name: file_name
    )
  end
end
