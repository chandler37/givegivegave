class AddWebsiteToCharity < ActiveRecord::Migration[5.1]
  def change
    add_column :charities, :website, :string
    add_index :charities, :website
  end
end
