# frozen_string_literal: true

module XStocks
  class Stock
    module Lists
      # Watchlist as a stock list
      class Watchlist
        TYPE = 'watchlist'

        def initialize(current_user)
          @current_user = current_user
        end

        def values
          current_user.watchlists.map { |watchlist| [watchlist.name, "#{TYPE}:#{watchlist.hashid}"] }
        end

        def stock_ids(hashid)
          watchlist = current_user.watchlists.find_by_hashid(hashid)
          XStocks::AR::Stock.where(symbol: watchlist.symbols).pluck(:id)
        end

        attr_reader :current_user
      end
    end
  end
end
