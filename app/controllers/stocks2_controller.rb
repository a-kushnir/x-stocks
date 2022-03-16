# frozen_string_literal: true

# Controller to provide stock information
class Stocks2Controller < ApplicationController
  include StocksHelper

  def index
    stocks = XStocks::AR::Stock.limit(10)

    return unless stale?(stocks)

    @columns = columns
    stocks = stocks.map { |stock| XStocks::Stock.new(stock) }
    @data = data(stocks)

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  private

  def columns
    columns = []

    columns << { label: 'Symbol', align: 'text-left pl-2' }
    columns << { label: 'Name', align: 'text-left', searchable: true, default: true }
    columns << { label: 'Country', align: 'text-center' }
    columns << { label: 'Price', align: 'text-right', default: true }
    columns << { label: 'Change', align: 'text-right', default: true }
    columns << { label: 'Change %', align: 'text-right pr-2', default: true }

    columns.each_with_index { |column, index| column[:index] = index + 1 }
    columns
  end

  def data(stocks)
    # positions = XStocks::AR::Position.where(stock_id: stocks.map(&:id), user: current_user).all
    # positions = positions.index_by(&:stock_id)
    flag = CountryFlag.new

    stocks.map do |stock|
      # position = positions[stock.id]
      [
        view_context.link_to(stock.symbol, stock_url(stock.symbol)), #, stock.logo_url, position&.note.presence],
        stock.company_name,
        flag.code(stock.country),
        view_context.number_to_currency(stock.current_price&.to_f),
        view_context.number_to_currency(stock.price_change&.to_f),
        view_context.number_to_percentage(stock.price_change_pct&.to_f, precision: 2),
      ]
    end
  end

  def value_or_warning(div_suspended, value)
    div_suspended ? 'Sus.' : value
  end
end
