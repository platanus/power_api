# rubocop:disable Metrics/ModuleLength
module PowerApi::GeneratorHelper::ActiveRecordResource
  extend ActiveSupport::Concern

  included do
    attr_reader :resource_attributes
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

    if attributes.count == 1 && attributes.first[:name] == :id
      raise PowerApi::GeneratorError.new("at least one attribute must be added")
    end

    @resource_attributes = attributes
  end

  def id
    "#{snake_case}_id"
  end

  def upcase
    snake_case.upcase
  end

  def upcase_plural
    plural.upcase
  end

  def camel
    resource_name.camelize
  end

  def camel_plural
    camel.pluralize
  end

  def plural
    snake_case.pluralize
  end

  def snake_case
    resource_name.underscore
  end

  def titleized
    resource_name.titleize
  end

  def plural_titleized
    plural.titleize
  end

  def path
    "app/models/#{snake_case}.rb"
  end

  def class_definition_line
    "class #{camel} < ApplicationRecord\n"
  end

  def attributes_names
    extract_attrs_names(resource_attributes)
  end

  def required_attributes_names
    extract_attrs_names(required_resource_attributes)
  end

  def permitted_attributes_names
    extract_attrs_names(permitted_attributes)
  end

  def permitted_attributes
    resource_attributes.reject do |attr|
      [:created_at, :updated_at, :id].include?(attr[:name])
    end
  end

  def required_resource_attributes(include_id: false)
    resource_attributes.select do |attr|
      attr[:required] || (include_id && attr[:name] == :id)
    end
  end

  def optional_resource_attributes
    permitted_attributes.reject { |attr| attr[:required] }
  end

  def attributes_symbols_text_list
    attrs_to_symobls_text_list(attributes_names)
  end

  def permitted_attributes_symbols_text_list
    attrs_to_symobls_text_list(permitted_attributes_names)
  end

  private

  def resource_name
    @resource_name
  end

  def extract_attrs_names(attrs)
    attrs.map { |attr| attr[:name] }
  end

  def attrs_to_symobls_text_list(attrs)
    attrs.map { |a| ":#{a}" }.join(",\n") + "\n"
  end

  def format_attributes(attrs)
    columns = resource_class.columns.inject([]) do |memo, col|
      col_name = col.name.to_sym

      memo << {
        name: col_name,
        type: col.type,
        swagger_type: get_swagger_type(col.type),
        required: required_attribute?(col_name),
        example: get_attribute_example(col.type, col_name)
      }

      memo
    end

    return columns if attrs.blank?

    attrs = (attrs.map(&:to_sym) + [:id]).uniq
    columns.select { |col| attrs.include?(col[:name]) }
  end

  def get_swagger_type(data_type)
    case data_type
    when :integer
      :integer
    when :float, :decimal
      :float
    when :boolean
      :boolean
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
      666
    when :float, :decimal
      6.66
    when :boolean
      true
    else
      "'Some #{col_name}'"
    end
  end

  def required_attribute?(col_name)
    validator_names = resource_class.validators_on(col_name).map do |validator|
      validator.class.name
    end

    validator_names.include?("ActiveRecord::Validations::PresenceValidator")
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
# rubocop:enable Metrics/ModuleLength
