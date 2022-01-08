class PowerApi::ControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def self.valid_actions
    PowerApi::GeneratorHelpers::PERMITTED_ACTIONS
  end

  class_option(
    :attributes,
    type: 'array',
    default: [],
    aliases: '-a',
    desc: 'attributes to show in serializer'
  )

  class_option(
    :controller_actions,
    type: 'array',
    default: [],
    desc: "actions to include in controller. Valid values: #{valid_actions.join(', ')}"
  )

  class_option(
    :version_number,
    type: 'numeric',
    default: nil,
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
    :parent_resource,
    type: 'string',
    default: nil,
    desc: "to indicate if the current resource is nested in another"
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
    if helper.parent_resource?
      if helper.resource_actions?
        add_normal_route(actions: helper.controller_actions & ["show", "update", "destroy"])
      end
      add_nested_route if helper.collection_actions?
    else
      add_normal_route(actions: helper.controller_actions)
    end

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
    return unless helper.versioned_api?

    create_swagger_schema
    add_swagger_schema_to_definition
    create_swagger_resource_spec
  end

  private

  def create_swagger_schema
    create_file(helper.swagger_resource_schema_path, helper.swagger_schema_tpl)
    helper.format_ruby_file(helper.swagger_resource_schema_path)
  end

  def add_swagger_schema_to_definition
    insert_into_file(
      helper.swagger_version_definition_path,
      helper.swagger_definition_entry,
      after: helper.swagger_definition_line_to_inject_schema
    )
  end

  def create_swagger_resource_spec
    create_file(helper.swagger_resource_spec_path, helper.swagger_resource_spec_tpl)
    helper.format_ruby_file(helper.swagger_resource_spec_path)
  end

  def add_nested_route
    line_to_replace = helper.parent_resource_routes_line_regex
    nested_resource_line = helper.resource_route_tpl(
      actions: helper.controller_actions & ['index', 'create']
    )
    add_nested_parent_route unless helper.parent_route_exist?

    if helper.parent_route_already_have_children?
      add_route(line_to_replace) { |match| "#{match}\n#{nested_resource_line}" }
    else
      add_route(line_to_replace) do |match|
        "#{match.delete_suffix('\n')} do\n#{nested_resource_line}\nend\n"
      end
    end
  end

  def add_normal_route(actions:)
    actions_for_only_option = actions.sort == self.class.valid_actions.sort ? [] : actions
    add_route(helper.api_current_route_namespace_line_regex) do |match|
      "#{match}\n#{helper.resource_route_tpl(actions: actions_for_only_option)}"
    end
  end

  def add_nested_parent_route
    add_route(helper.api_current_route_namespace_line_regex) do |match|
      "#{match}\n#{helper.resource_route_tpl(is_parent: true)}"
    end
  end

  def add_route(line_to_replace, &block)
    gsub_file helper.routes_path, line_to_replace do |match|
      block.call(match)
    end
  end

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new(
      version_number: options[:version_number],
      resource: file_name,
      authenticated_resource: options[:authenticate_with],
      parent_resource: options[:parent_resource],
      owned_by_authenticated_resource: options[:owned_by_authenticated_resource],
      resource_attributes: options[:attributes],
      controller_actions: options[:controller_actions],
      use_paginator: options[:use_paginator],
      allow_filters: options[:allow_filters]
    )
  end
end
