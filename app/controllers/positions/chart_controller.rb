# frozen_string_literal: true

module Positions
  # Chart representation of user portfolio positions
  class ChartController < ApplicationController
    def index
      return unless stale?(positions)

      @positions = positions.to_a
      @stocks_by_id = XStocks::Stock.find_all(id: @positions.map(&:stock_id)).index_by(&:id)

      @page_title = t('positions.pages.portfolio')
      @page_menu_item = :positions
    end

    private

    def positions
      @positions ||= current_user.positions.with_shares.all
    end
  end
end
