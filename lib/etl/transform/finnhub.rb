module Etl
  module Transform
    class Finnhub

      def company(stock, json)
        stock.ipo = json['ipo']
        stock.logo = json['logo']
        stock.save
      end

      def peers(stock, json)
        peers = (json || []).select { |p| p != stock.symbol }
        ::StocksTag.batch_update(stock, :stock_peer, peers)
      end

      def quote(stock, json)
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
