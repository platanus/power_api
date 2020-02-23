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

  class_option(
    :use_paginator,
    type: 'boolean',
    default: false,
    desc: 'to indicate whether the controller will use pager or not'
  )

  class_option(
    :allow_filters,
    type: 'boolean',
    default: false,
    desc: 'to indicate whether the controller will allow query string filters or not'
  )

  class_option(
    :authenticate_with,
    type: 'string',
    default: nil,
    desc: "to indicate if authorization is required to access the controller"
  )

  class_option(
    :owned_by_authenticated_resource,
    type: 'boolean',
    default: false,
    desc: "to indicate if the resource's owner must be the authorized resource"
  )

  def create_controller
    create_file(
      helper.resource_controller_path,
      helper.resource_controller_tpl
    )

    helper.format_ruby_file(helper.resource_controller_path)
  end

  def add_routes
    insert_into_file(
      helper.routes_path,
      helper.resource_route_tpl,
      after: helper.routes_line_to_inject_resource
    )

    helper.format_ruby_file(helper.routes_path)
  end

  def create_serializer
    create_file(
      helper.ams_serializer_path,
      helper.ams_serializer_tpl
    )

    helper.format_ruby_file(helper.ams_serializer_path)
  end

  def configure_swagger
    create_file(
      helper.swagger_resource_schema_path,
      helper.swagger_schema_tpl
    )

    helper.format_ruby_file(helper.swagger_resource_schema_path)

    insert_into_file(
      helper.swagger_version_definition_path,
      helper.swagger_definition_entry,
      after: helper.swagger_definition_line_to_inject_schema
    )

    create_file(
      helper.swagger_resource_spec_path,
      helper.swagger_resource_spec_tpl
    )

    helper.format_ruby_file(helper.swagger_resource_spec_path)
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new(
      version_number: options[:version_number],
      resource: file_name,
      authenticated_resource: options[:authenticate_with],
      owned_by_authenticated_resource: options[:owned_by_authenticated_resource],
      resource_attributes: options[:attributes],
      use_paginator: options[:use_paginator],
      allow_filters: options[:allow_filters]
    )
  end
end
