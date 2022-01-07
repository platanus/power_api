# rubocop:disable Metrics/ModuleLength
module PowerApi::GeneratorHelper::ControllerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::ApiHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::PaginationHelper
    include PowerApi::GeneratorHelper::SimpleTokenAuthHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper
    include PowerApi::GeneratorHelper::ControllerActionsHelper

    attr_accessor :allow_filters
  end

  def api_base_controller_path
    "app/controllers/api/base_controller.rb"
  end

  def base_controller_path
    "app/controllers/api/v#{version_number}/base_controller.rb"
  end

  def resource_controller_path
    "app/controllers/api/v#{version_number}/#{resource.plural}_controller.rb"
  end

  def api_base_controller_tpl
    <<~CONTROLLER
      class Api::BaseController < PowerApi::BaseController
      end
    CONTROLLER
  end

  def base_controller_tpl
    <<~CONTROLLER
      class Api::V#{version_number}::BaseController < Api::BaseController
        before_action do
          self.namespace_for_serializer = ::Api::V#{version_number}
        end
      end
    CONTROLLER
  end

  def resource_controller_tpl
    tpl_class(
      ctrl_tpl_class_definition_line,
      ctrl_tpl_acts_as_token_authentication_handler,
      ctrl_tpl_index,
      ctrl_tpl_show,
      ctrl_tpl_create,
      ctrl_tpl_update,
      ctrl_tpl_destroy,
      "private",
      ctrl_tpl_resource,
      ctrl_tpl_resources_from_authenticated_resource,
      ctrl_tpl_find_parent_resource,
      ctrl_tpl_permitted_params
    )
  end

  private

  def ctrl_tpl_class_definition_line
    "Api::V#{version_number}::#{resource.camel_plural}Controller < \
Api::V#{version_number}::BaseController"
  end

  def ctrl_tpl_acts_as_token_authentication_handler
    return unless authenticated_resource?

    "acts_as_token_authentication_handler_for #{authenticated_resource.camel}, \
fallback: :exception\n"
  end

  def ctrl_tpl_index
    return unless index?

    concat_tpl_method("index", "respond_with #{ctrl_tpl_index_resources}")
  end

  def ctrl_tpl_show
    return unless show?

    concat_tpl_method("show", "respond_with #{resource.snake_case}")
  end

  def ctrl_tpl_create
    return unless create?

    concat_tpl_method("create", "respond_with #{ctrl_tpl_create_resource}")
  end

  def ctrl_tpl_update
    return unless update?

    concat_tpl_method(
      "update",
      "respond_with #{resource.snake_case}.update!(#{resource.snake_case}_params)"
    )
  end

  def ctrl_tpl_destroy
    return unless destroy?

    concat_tpl_method("destroy", "respond_with #{resource.snake_case}.destroy!")
  end

  def ctrl_tpl_resource
    return unless resource_actions?

    concat_tpl_method(resource.snake_case, "@#{resource.snake_case} ||= #{ctrl_tpl_find_resource}")
  end

  def ctrl_tpl_permitted_params
    return unless update_or_create?

    concat_tpl_method(
      "#{resource.snake_case}_params",
      "params.require(:#{resource.snake_case}).permit(",
      "#{resource.permitted_attributes_symbols_text_list})"
    )
  end

  def ctrl_tpl_find_resource
    find_statement = "find_by!(id: params[:id])"
    resource_source = if owned_by_authenticated_resource?
                        if parent_resource?
                          "#{resource.camel}.where(#{parent_resource.snake_case}: \
#{current_authenticated_resource}.#{parent_resource.plural})"
                        else
                          resource.plural
                        end
                      else
                        resource.camel
                      end

    "#{resource_source}.#{find_statement}"
  end

  def ctrl_tpl_index_resources
    return ctrl_tpl_index_collection unless use_paginator

    "paginate(#{ctrl_tpl_index_collection})"
  end

  def ctrl_tpl_index_collection
    collection = owned_resource? ? resource.plural : "#{resource.camel}.all"
    return collection unless allow_filters

    "filtered_collection(#{collection})"
  end

  def ctrl_tpl_create_resource
    create_statement = "create!(#{resource.snake_case}_params)"

    if owned_resource?
      "#{resource.plural}.#{create_statement}"
    else
      "#{resource.camel}.#{create_statement}"
    end
  end

  def ctrl_tpl_resources_from_authenticated_resource
    return unless owned_resource?

    resource_source = if owned_by_authenticated_resource? && !parent_resource?
                        current_authenticated_resource
                      else
                        parent_resource.snake_case
                      end

    concat_tpl_method(
      resource.plural,
      "@#{resource.plural} ||= #{resource_source}.#{resource.plural}"
    )
  end

  def ctrl_tpl_find_parent_resource
    return unless parent_resource?

    resource_source = if owned_by_authenticated_resource?
                        "#{current_authenticated_resource}.#{parent_resource.plural}"
                      else
                        parent_resource.camel
                      end

    concat_tpl_method(
      parent_resource.snake_case,
      "@#{parent_resource.snake_case} ||= #{resource_source}.\
find_by!(id: params[:#{parent_resource.id}])"
    )
  end

  def owned_resource?
    owned_by_authenticated_resource? || parent_resource?
  end
end
# rubocop:enable Metrics/ModuleLength
