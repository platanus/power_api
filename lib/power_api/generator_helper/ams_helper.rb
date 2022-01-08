module PowerApi::GeneratorHelper::AmsHelper
  extend ActiveSupport::Concern

  included do
    include PowerApi::GeneratorHelper::ApiHelper
    include PowerApi::GeneratorHelper::ResourceHelper
  end

  def ams_initializer_path
    "config/initializers/active_model_serializers.rb"
  end

  def ams_serializer_path
    "app/serializers/#{api_file_path}/#{resource.snake_case}_serializer.rb"
  end

  def ams_serializers_path
    "app/serializers/#{api_file_path}/.gitkeep"
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
      class #{api_class}::#{resource.camel}Serializer < ActiveModel::Serializer
        type :#{resource.snake_case}

        attributes(
          #{resource.attributes_symbols_text_list})
      end
    SERIALIZER
  end
end
