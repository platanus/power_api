class Api::V1::BlogSerializer < ActiveModel::Serializer
  type :blog

  attributes :title, :body, :created_at, :updated_at
end
