# rubocop:disable Layout/AlignParameters
module PowerApi::GeneratorHelper::RoutesHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::ApiHelper
    include PowerApi::GeneratorHelper::ResourceHelper
    include PowerApi::GeneratorHelper::TemplateBuilderHelper
  end

  def routes_path
    "config/routes.rb"
  end

  def routes_line_to_inject_new_version
    return routes_first_line if first_version?

    "'/api' do\n"
  end

  def routes_first_line
    "routes.draw do\n"
  end

  def api_version_routes_line_regex
    /#{version_class}[^\n]*/
  end

  def parent_resource_routes_line_regex
    /#{parent_resource_route_tpl}[^\n]*/
  end

  def version_route_tpl
    return first_version_route_tpl if first_version?

    new_version_route_tpl
  end

  def internal_route_tpl
    concat_tpl_statements(
      "namespace :api do",
        "namespace :internal do",
        "end",
      "end\n"
    )
  end

  def resource_route_tpl(actions: [], is_parent: false)
    res = (is_parent ? parent_resource : resource).plural
    line = "resources :#{res}"
    line += ", only: [#{actions.map { |a| ":#{a}" }.join(', ')}]" if actions.any?
    line
  end

  def parent_route_exist?
    routes_match_regex?(/#{parent_resource_route_tpl}/)
  end

  def parent_route_already_have_children?
    routes_match_regex?(/#{parent_resource_route_tpl}[\W\w]*do/)
  end

  private

  def resource_route_statements(actions: [])
    line = "resources :#{resource.plural}"
    line += ", only: [#{actions.map { |a| ":#{a}" }.join(', ')}]" if actions.any?
    line
  end

  def routes_match_regex?(regex)
    path = File.join(Rails.root, routes_path)
    File.readlines(path).grep(regex).any?
  end

  def parent_resource_route_tpl
    raise PowerApi::GeneratorError.new("missing parent_resource") unless parent_resource?

    "resources :#{parent_resource.plural}"
  end

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
    "module: '#{version_class}', \
path: { value: 'v#{version_number}' }, \
defaults: { format: 'json' }"
  end
end
# rubocop:enable Layout/AlignParameters
