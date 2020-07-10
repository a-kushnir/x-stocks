module Convert
  module Finnhub
    class Quote

      def process(stock, json)
        stock.current_price = json['c']
        stock.prev_close_price = json['pc']
        stock.open_price = json['o']
        stock.day_low_price = json['l']
        stock.day_high_price = json['h']
        stock.update_prices!
      end

    end
  end
end
