module PowerApi::GeneratorHelper::ResourceHelper
  extend ActiveSupport::Concern

  class Resource
    include PowerApi::GeneratorHelper::ActiveRecordResource

    def initialize(resource_name)
      self.resource_name = resource_name
    end
  end

  included do
    attr_reader :resource, :parent_resource
  end

  def resource=(value)
    @resource = Resource.new(value)
  end

  def parent_resource=(value)
    return if value.blank?

    @parent_resource = Resource.new(value)
  end

  def resource_attributes=(collection)
    resource.resource_attributes = collection
  end

  def parent_resource?
    !!parent_resource
  end
end
