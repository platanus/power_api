module PowerApi::GeneratorHelper::ControllerActionsHelper
  extend ActiveSupport::Concern

  PERMITTED_ACTIONS = ['index', 'create', 'show', 'update', 'destroy']

  attr_reader :controller_actions

  def controller_actions=(actions)
    @controller_actions = actions.blank? ? PERMITTED_ACTIONS : actions & PERMITTED_ACTIONS
  end

  def index?
    controller_actions.include?('index')
  end

  def create?
    controller_actions.include?('create')
  end

  def show?
    controller_actions.include?('show')
  end

  def update?
    controller_actions.include?('update')
  end

  def destroy?
    controller_actions.include?('destroy')
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
