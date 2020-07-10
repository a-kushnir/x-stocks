module Convert
  module Finnhub
    class Peers

      def process(stock, json)
        ::StocksTag.batch_update(stock, :stock_peer, json)
      end

    end
  end
end
