class HourlyUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    update_stock_prices
  end

  def update_needed?
    StockQuote.where('updated_at < ?', 1.hour.ago).exists?
  end

  def update_stock_prices
    Stock.all.each do |stock|
      json = Import::Finnhub.new.quote(stock.symbol)
      Convert::Finnhub::Quote.new.process(stock, json)
      sleep(1.0/30) # Limit up to 30 requests per second
    end
  end
end
