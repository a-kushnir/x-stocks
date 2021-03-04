class AddStockYahooFairPrice < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :yahoo_fair_price, :decimal, precision: 10, scale: 2
  end
end
