module PowerApi::GeneratorHelper::ResourceHelper
  extend ActiveSupport::Concern

  included do
    attr_reader :resource_name, :resource_attributes
  end

  def resource_name=(value)
    @resource_name = value

    if !resource_class
      raise PowerApi::GeneratorError.new(
        "Invalid resource name. Must be the snake_case representation of a ruby class"
      )
    end

    if !resource_is_active_record_model?
      raise PowerApi::GeneratorError.new("resource is not an active record model")
    end
  end

  def resource_attributes=(collection)
    attributes = format_attributes(collection)
    raise PowerApi::GeneratorError.new("at least one attribute must be added") if attributes.none?

    @resource_attributes = attributes
  end

  def upcase_resource
    snake_case_resource.upcase
  end

  def upcase_plural_resource
    plural_resource.upcase
  end

  def camel_resource
    resource_name.camelize
  end

  def camel_plural_resource
    camel_resource.pluralize
  end

  def plural_resource
    snake_case_resource.pluralize
  end

  def snake_case_resource
    resource_name.underscore
  end

  def resource_attributes_names
    resource_attributes.map { |attr| attr[:name] }
  end

  def resource_attributes_symbols_text_list
    resource_attributes_names.map { |a| ":#{a}" }.join(', ')
  end

  private

  def format_attributes(attrs)
    columns = resource_class.columns.inject([]) do |memo, col|
      col_name = col.name.to_sym
      next memo if col_name == :id

      memo << {
        name: col_name,
        type: col.type,
        swagger_type: get_swagger_type(col.type),
        example: get_attribute_example(col.type, col_name)
      }

      memo
    end

    return columns if attrs.blank?

    attrs = attrs.map(&:to_sym)
    columns.select { |col| attrs.include?(col[:name]) }
  end

  def get_swagger_type(data_type)
    case data_type
    when :integer
      :integer
    when :float, :decimal
      :float
    else
      :string
    end
  end

  def get_attribute_example(data_type, col_name)
    case data_type
    when :date
      "'1984-06-04'"
    when :datetime
      "'1984-06-04 09:00'"
    when :integer
      rand(1000)
    when :float, :decimal
      (rand(100) / 200.0).round(2)
    else
      "'Some #{col_name}'"
    end
  end

  def resource_class
    resource_name.classify.constantize
  rescue NameError
    false
  end

  def resource_is_active_record_model?
    !!ActiveRecord::Base.descendants.find { |model_class| model_class == resource_class }
  end
end
