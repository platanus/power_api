module PowerApi::GeneratorHelper::AmsHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::VersionHelper
    include PowerApi::GeneratorHelper::ResourceHelper
  end

  def ams_initializer_path
    "config/initializers/active_model_serializers.rb"
  end

  def ams_serializer_path
    "app/serializers/api/v#{version_number}/#{snake_case_resource}_serializer.rb"
  end

  def ams_serializers_path
    "app/serializers/api/v#{version_number}/.gitkeep"
  end

  def ams_initializer_tpl
    <<~INITIALIZER
      class ActiveModelSerializers::Adapter::JsonApi
        def self.default_key_transform
          :unaltered
        end
      end

      ActiveModelSerializers.config.adapter = :json_api
    INITIALIZER
  end

  def ams_serializer_tpl
    <<~SERIALIZER
      class Api::V#{version_number}::#{camel_resource}Serializer < ActiveModel::Serializer
        type :#{snake_case_resource}

        attributes(
          #{resource_attributes_symbols_text_list})
      end
    SERIALIZER
  end
end
