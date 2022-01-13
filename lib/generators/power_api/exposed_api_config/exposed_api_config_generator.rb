class PowerApi::ExposedApiConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  class_option(
    :authenticated_resources,
    type: 'array',
    default: [],
    desc: 'define which model or models will be token authenticatable'
  )

  def add_base_controller
    create_file(
      helper.exposed_base_controller_path,
      helper.exposed_base_controller_tpl
    )
  end

  def install_rswag
    generate "rswag:ui:install"
    generate "rswag:api:install"
    generate "rswag:specs:install"

    create_file(helper.rswag_ui_initializer_path, helper.rswag_ui_initializer_tpl, force: true)
    create_file(helper.swagger_helper_path, helper.swagger_helper_tpl, force: true)
    create_file(helper.spec_swagger_path)
    create_file(helper.spec_integration_path)
  end

  def install_first_version
    generate "power_api:version 1"
  end

  def install_simple_token_auth
    create_file(
      helper.simple_token_auth_initializer_path,
      helper.simple_token_auth_initializer_tpl,
      force: true
    )

    helper.authenticated_resources.each do |resource|
      generate resource.authenticated_resource_migration

      insert_into_file(
        resource.path,
        helper.simple_token_auth_method,
        after: resource.class_definition_line
      )
    end
  end

  private

  def helper
    @helper ||= PowerApi::GeneratorHelpers.new(
      authenticated_resources: options[:authenticated_resources]
    )
  end
end
