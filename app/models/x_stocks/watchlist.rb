# frozen_string_literal: true

module XStocks
  # User Watchlist Model
  class Watchlist
    def initialize(ar_watchlist)
      @ar_watchlist = ar_watchlist
      ar_watchlist.symbols ||= []
    end

    def toggle(stock, included)
      if included
        ar_watchlist.symbols.push(stock.symbol)
      else
        ar_watchlist.symbols.delete(stock.symbol)
      end
    end

    def save
      ar_watchlist.symbols = ar_watchlist.symbols.compact.uniq.sort
      ar_watchlist.save if ar_watchlist.changed?
    end

    attr_reader :ar_watchlist

    delegate :hashid, to: :ar_watchlist
    XStocks::ARForwarder.delegate_methods(self, :ar_watchlist, XStocks::AR::Watchlist)
  end
end
