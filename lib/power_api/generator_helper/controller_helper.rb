module PowerApi::GeneratorHelper::ControllerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::VersionHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::PaginationHelper
    include PowerApi::GeneratorHelper::SimpleTokenAuthHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper

    attr_accessor :allow_filters
  end

  def api_base_controller_path
    "app/controllers/api/base_controller.rb"
  end

  def base_controller_path
    "app/controllers/api/v#{version_number}/base_controller.rb"
  end

  def resource_controller_path
    "app/controllers/api/v#{version_number}/#{plural_resource}_controller.rb"
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
      ctrl_tpl_permitted_params
    )
  end

  private

  def ctrl_tpl_class_definition_line
    "Api::V#{version_number}::#{camel_plural_resource}Controller < \
Api::V#{version_number}::BaseController"
  end

  def ctrl_tpl_acts_as_token_authentication_handler
    return unless authenticated_resource?

    "acts_as_token_authentication_handler_for #{authenticated_resource.camel_resource}, \
fallback: :exception\n"
  end

  def ctrl_tpl_index
    concat_tpl_method("index", "respond_with #{ctrl_tpl_index_resources}")
  end

  def ctrl_tpl_show
    concat_tpl_method("show", "respond_with #{snake_case_resource}")
  end

  def ctrl_tpl_create
    concat_tpl_method("create", "respond_with #{ctrl_tpl_create_resource}")
  end

  def ctrl_tpl_update
    concat_tpl_method(
      "update",
      "respond_with #{snake_case_resource}.update!(#{snake_case_resource}_params)"
    )
  end

  def ctrl_tpl_destroy
    concat_tpl_method("destroy", "respond_with #{snake_case_resource}.destroy!")
  end

  def ctrl_tpl_resource
    concat_tpl_method(snake_case_resource, "@#{snake_case_resource} ||= #{resource_from_params}")
  end

  def ctrl_tpl_permitted_params
    concat_tpl_method(
      "#{snake_case_resource}_params",
      "params.require(:#{snake_case_resource}).permit(",
      "#{permitted_attributes_symbols_text_list})"
    )
  end

  def resource_from_params
    find_statement = "find_by!(id: params[:id])"

    if owned_by_authenticated_resource?
      "#{plural_resource}.#{find_statement}"
    else
      "#{camel_resource}.#{find_statement}"
    end
  end

  def ctrl_tpl_index_resources
    return ctrl_tpl_index_collection unless use_paginator

    "paginate(#{ctrl_tpl_index_collection})"
  end

  def ctrl_tpl_index_collection
    collection = owned_by_authenticated_resource? ? plural_resource : "#{camel_resource}.all"
    return collection unless allow_filters

    "filtered_collection(#{collection})"
  end

  def ctrl_tpl_create_resource
    create_statement = "create!(#{snake_case_resource}_params)"

    if owned_by_authenticated_resource?
      "#{plural_resource}.#{create_statement}"
    else
      "#{camel_resource}.#{create_statement}"
    end
  end

  def ctrl_tpl_resources_from_authenticated_resource
    return unless owned_by_authenticated_resource?

    concat_tpl_method(
      plural_resource,
      "@#{plural_resource} ||= #{current_resource}.#{plural_resource}"
    )
  end
end
