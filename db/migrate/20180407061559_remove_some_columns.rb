class RemoveSomeColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :charities, :score_financial, :float
    remove_column :charities, :score_accountability, :float
    remove_column :charities, :stars_financial, :integer
    remove_column :charities, :stars_accountability, :integer
  end
end
