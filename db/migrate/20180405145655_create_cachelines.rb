class CreateCachelines < ActiveRecord::Migration[5.1]
  def change
    create_table :cachelines do |t|
      t.string :url_minus_auth
      t.text :body
      t.integer :http_status

      t.timestamps

      t.index :url_minus_auth, unique: true
    end
  end
end
