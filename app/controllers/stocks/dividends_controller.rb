# frozen_string_literal: true

module Stocks
  # Stock Dividends
  class DividendsController < ApplicationController
    etag { @stock }
    etag { params }

    def index
      @stock = find_stock

      render partial: params[:less] ? 'stocks/dividends/less' : 'stocks/dividends/more'
    end

    private

    def find_stock
      XStocks::Stock.find_by_symbol(params[:stock_symbol])
    end
  end
end
