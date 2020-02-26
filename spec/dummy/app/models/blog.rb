class Blog < ApplicationRecord
  belongs_to :portfolio, required: false

  validates :title, :body, presence: true
end
