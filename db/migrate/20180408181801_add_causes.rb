class AddCauses < ActiveRecord::Migration[5.1]
  def change
    create_table :causes do |t|
      t.string :name
      t.text :description
      t.integer :parent_id, limit: 8

      t.timestamps null: false

      t.index :parent_id
    end

    create_table :causes_charities, id: false do |t|
      t.integer :cause_id, limit: 8
      t.integer :charity_id, limit: 8

      t.index :cause_id
      t.index :charity_id
    end
  end
end
