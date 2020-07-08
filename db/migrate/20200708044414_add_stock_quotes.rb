class AddStockQuotes < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_quotes do |t|
      t.references :stock, null: false
      t.decimal :current_price, precision: 10, scale: 2
      t.decimal :prev_close_price, precision: 10, scale: 2
      t.decimal :open_price, precision: 10, scale: 2
      t.decimal :day_low_price, precision: 10, scale: 2
      t.decimal :day_high_price, precision: 10, scale: 2
      t.datetime :timestamp
      t.datetime :updated_at, null: false
    end
  end
end
