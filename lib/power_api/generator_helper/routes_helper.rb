# rubocop:disable Layout/AlignArguments
module PowerApi::GeneratorHelper::RoutesHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::VersionHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper
  end

  def routes_path
    "config/routes.rb"
  end

  def routes_line_to_inject_new_version
    return "routes.draw do\n" if first_version?

    "'/api' do\n"
  end

  def routes_line_to_inject_resource
    /Api::V#{version_number}[^\n]*/
  end

  def version_route_tpl
    return first_version_route_tpl if first_version?

    new_version_route_tpl
  end

  def resource_route_tpl
    "\nresources :#{resource.plural}"
  end

  private

  def first_version_route_tpl
    concat_tpl_statements(
      "scope path: '/api' do",
        "api_version(#{api_version_params}) do",
        "end",
      "end\n"
    )
  end

  def new_version_route_tpl
    concat_tpl_statements(
      "api_version(#{api_version_params}) do",
      "end"
    )
  end

  def api_version_params
    "module: 'Api::V#{version_number}', \
path: { value: 'v#{version_number}' }, \
defaults: { format: 'json' }"
  end
end
# rubocop:enable Layout/AlignArguments
