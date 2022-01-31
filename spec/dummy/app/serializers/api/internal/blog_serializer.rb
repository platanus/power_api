class Api::Internal::BlogSerializer < ActiveModel::Serializer
  type :blog

  attributes(
    :id,
    :title,
    :body,
    :created_at,
    :updated_at,
    :portfolio_id
  )
end
