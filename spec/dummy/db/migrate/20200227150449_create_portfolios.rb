class CreatePortfolios < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolios do |t|
      t.string :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
