class PowerApi::VersionGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  argument :version_number, type: :string, required: true

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

  private

  def helper
    @helper ||= PowerApi::VersionGeneratorHelper.new(version_number: version_number)
  end
end
