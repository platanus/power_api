BLOG_SCHEMA = {
  type: :object,
  properties: {
    id: { type: :string, example: '1' },
    type: { type: :string, example: 'blog' },
    attributes: {
      type: :object,
      properties: {
        title: { type: :string, example: 'Some title' },
        body: { type: :string, example: 'Some body' },
        created_at: { type: :string, example: '1984-06-04 09:00' },
        updated_at: { type: :string, example: '1984-06-04 09:00' }
      },
      required: [
        :title,
        :body,
        :created_at,
        :updated_at
      ]
    }
  },
  required: [
    :id,
    :type,
    :attributes
  ]
}
