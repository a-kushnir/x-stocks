# frozen_string_literal: true

module Stocks
  # Stock Watchlists
  class WatchlistsController < ApplicationController
    def create
      @stock = find_stock

      current_user.watchlists.each do |watchlist|
        watchlist = XStocks::Watchlist.new(watchlist)
        watchlist.toggle(@stock, watchlists.include?(watchlist.hashid))
        watchlist.save
      end

      params[:watchlist_menu] = true
    end

    private

    def find_stock
      XStocks::Stock.find_by_symbol(params[:stock_symbol])
    end

    def watchlists
      params.fetch(:watchlists, [])
    end
  end
end
