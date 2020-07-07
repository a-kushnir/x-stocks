module Convert
  module Finnhub
    class Peers

      def process(stock, json)
        update_peers(stock, json)
      end

      private

      def update_peers(stock, json)
        updated_ids = []
        (json || []).each do |peer|
          peer_stock = Stock.find_by(symbol: peer)
          company_peer = peer_stock ?
                  ::CompanyPeer.find_or_create_by(stock: stock, peer_symbol: peer, peer_stock: peer_stock) :
                  ::CompanyPeer.find_or_create_by(stock: stock, peer_symbol: peer)
          updated_ids << company_peer.id
        end

        ::CompanyPeer
            .where(stock_id: stock.id)
            .where.not(id: updated_ids)
            .delete_all
      end

    end
  end
end
