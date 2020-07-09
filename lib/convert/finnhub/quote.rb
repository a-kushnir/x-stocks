module Convert
  module Finnhub
    class Quote

      def process(stock, json)
        update_quote(stock, json)
      end

      private

      def update_quote(stock, json)
        quote = stock.stock_quote || ::StockQuote.new(stock: stock)

        quote.current_price = json['c']
        quote.prev_close_price = json['pc']
        quote.open_price = json['o']
        quote.day_low_price = json['l']
        quote.day_high_price = json['h']
        quote.timestamp = DateTime.strptime(json['t'].to_s,'%s')

        quote.price_change = (quote.current_price - quote.prev_close_price) rescue nil
        quote.price_change_pct = (quote.price_change / quote.prev_close_price * 100) rescue nil

        quote.save
      end
    end
  end
end
