module PowerApi::GeneratorHelper::ControllerHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::VersionHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::PaginationHelper

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
    <<~CONTROLLER
      class Api::V#{version_number}::#{camel_plural_resource}Controller < Api::V#{version_number}::BaseController
        def index
          respond_with #{index_resources}
        end

        def show
          respond_with #{snake_case_resource}
        end

        def create
          respond_with #{camel_resource}.create!(#{snake_case_resource}_params)
        end

        def update
          respond_with #{snake_case_resource}.update!(#{snake_case_resource}_params)
        end

        def destroy
          #{snake_case_resource}.destroy!
        end

        private

        def #{snake_case_resource}
          @#{snake_case_resource} ||= #{camel_resource}.find_by!(id: params[:id])
        end

        def #{snake_case_resource}_params
          params.require(:#{snake_case_resource}).permit(
            #{permitted_attributes_symbols_text_list}
          )
        end
      end
    CONTROLLER
  end

  private

  def index_resources
    return index_collection unless use_paginator

    "paginate(#{index_collection})"
  end

  def index_collection
    collection = "#{camel_resource}.all"
    return collection unless allow_filters

    "filtered_collection(#{collection})"
  end
end
