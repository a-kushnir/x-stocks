class AddStockFields < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :yahoo_discount, :integer, null: true
  end
end
