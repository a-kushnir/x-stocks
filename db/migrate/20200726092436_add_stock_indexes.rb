class AddStockIndexes < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :sp500, :boolean
    add_column :stocks, :nasdaq100, :boolean
    add_column :stocks, :dowjones, :boolean
  end
end
