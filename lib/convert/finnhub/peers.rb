module Convert
  module Finnhub
    class Peers

      def process(stock, json)
        peers = (json || []).select { |p| p != stock.symbol }
        ::StocksTag.batch_update(stock, :stock_peer, peers)
      end

    end
  end
end
