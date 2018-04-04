class MakeEinUnique < ActiveRecord::Migration[5.1]
  def change
    add_index :charities, :ein, unique: true
  end
end
