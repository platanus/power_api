module PowerApi::GeneratorHelper::ControllerActionsHelper
  extend ActiveSupport::Concern

  PERMITTED_ACTIONS = ['index', 'create', 'show', 'update', 'destroy']

  attr_reader :controller_actions

  def controller_actions=(actions)
    @controller_actions = actions.blank? ? PERMITTED_ACTIONS : actions & PERMITTED_ACTIONS
  end

  PERMITTED_ACTIONS.each do |action|
    define_method("#{action}?") { controller_actions.include?(action) }
  end

  def resource_actions?
    show? || update? || destroy?
  end

  def collection_actions?
    index? || create?
  end

  def update_or_create?
    update? || create?
  end
end
