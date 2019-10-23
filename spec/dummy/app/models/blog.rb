class Blog < ApplicationRecord
  validates :title, :body, presence: true
end
