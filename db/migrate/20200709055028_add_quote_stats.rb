class AddQuoteStats < ActiveRecord::Migration[6.0]
  def change
    add_column :stock_quotes, :price_change, :decimal, precision: 10, scale: 2
    add_column :stock_quotes, :price_change_pct, :decimal, precision: 10, scale: 2
    StockQuote.reset_column_information
    StockQuote.update_all('price_change = current_price - prev_close_price') if column_exists?(:stock_quotes, :price_change)
    StockQuote.update_all('price_change_pct = price_change / prev_close_price * 100') if column_exists?(:stock_quotes, :price_change_pct)
  end
end
