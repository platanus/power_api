class PowerApi::VersionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def modify_routes
    insert_into_file("config/routes.rb", after: helper.routes_line_to_inject_new_version) do
      helper.version_route_template
    end
  end

  def add_base_controller
    create_file(
      helper.base_controller_path,
      helper.base_controller_template
    )
  end

  def add_serializers_directory
    create_file(helper.serializers_path)
  end

  def add_swagger_related
    create_file(helper.swagger_schemas_path)

    create_file(
      helper.swagger_version_definition_path,
      helper.swagger_definition_template
    )

    insert_into_file("spec/swagger_helper.rb", after: helper.swagger_helper_api_definition_line) do
      helper.swagger_helper_api_definition
    end
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new(version_number: file_name)
  end
end
