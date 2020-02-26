class AddPortfolioIdBlogs < ActiveRecord::Migration[5.2]
  def change
    add_reference :blogs, :portfolio, foreign_key: true, index: true
  end
end
