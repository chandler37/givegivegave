class CreateCharities < ActiveRecord::Migration[5.1]
  def change
    create_table :charities do |t|
      t.string :name
      t.string :ein
      t.text :description
      t.float :score_overall
      t.float :score_financial
      t.float :score_accountability
      t.integer :stars_overall
      t.integer :stars_financial
      t.integer :stars_accountability

      t.timestamps
    end
  end
end
