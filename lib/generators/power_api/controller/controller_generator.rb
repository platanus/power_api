class PowerApi::ControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option(
    :attributes,
    type: 'array',
    default: [],
    aliases: '-a',
    desc: 'attributes to show in serializer'
  )

  class_option(
    :version_number,
    type: 'numeric',
    default: 1,
    aliases: '-v',
    desc: 'the API version number you want to add this controller'
  )

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

  def create_serializer
    create_file(
      helper.get_serializer_path,
      helper.generate_serializer_tpl
    )
  end

  private

  def helper
    @helper ||= PowerApi::ControllerGeneratorHelper.new(
      version_number: options[:version_number],
      resource_name: file_name,
      resource_attributes: options[:attributes]
    )
  end
end
