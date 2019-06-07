class PowerApi::ControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :version_number, type: :string, required: true

  def create_controller
    create_file(
      helper.get_controller_path,
      helper.generate_controller_tpl
    )
  end

  def add_routes
    insert_into_file(
      "config/routes.rb",
      helper.resource_route_template,
      after: helper.routes_line_to_inject_resource
    )
  end

  private

  def helper
    PowerApi::ControllerGeneratorHelper.new(
      version_number: version_number,
      resource_name: file_name
    )
  end
end
