class PowerApi::VersionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def modify_routes
    insert_into_file(
      helper.routes_path,
      after: helper.routes_line_to_inject_new_version
    ) do
      helper.version_route_tpl
    end

    helper.format_ruby_file(helper.routes_path)
  end

  def add_base_controller
    create_file(
      helper.version_base_controller_path,
      helper.version_base_controller_tpl
    )
  end

  def add_serializers_directory
    create_file(helper.ams_serializers_path)
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new(version_number: file_name)
  end
end
