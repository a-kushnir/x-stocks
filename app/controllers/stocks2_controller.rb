# frozen_string_literal: true

# Controller to provide stock information
class Stocks2Controller < ApplicationController
  def index
    @pagy, stocks = pagy XStocks::AR::Stock.reorder(sort_column => sort_direction), items: params.fetch(:count, 10)

    return unless stale?(stocks)

    @columns = columns
    stocks = stocks.map { |stock| XStocks::Stock.new(stock) }
    @data = data(stocks)

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  private

  def sort_column
    %w[symbol company_name country current_price price_change price_change_pct].include?(params[:sort]) ? params[:sort] : 'symbol'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def columns
    columns = []

    columns << { label: 'Symbol', column: 'symbol', align: 'text-left pl-2' }
    columns << { label: 'Name', column: 'company_name', align: 'text-left', searchable: true, default: true }
    columns << { label: 'Country', column: 'country', align: 'text-center' }
    columns << { label: 'Price', column: 'current_price', align: 'text-right', default: true }
    columns << { label: 'Change', column: 'price_change', align: 'text-right', default: true }
    columns << { label: 'Change %', column: 'price_change_pct', align: 'text-right pr-2', default: true }

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
        view_context.link_to(stock.symbol, stock_url(stock.symbol), class: 'text-blue-500 no-underline'), # , stock.logo_url, position&.note.presence],
        stock.company_name,
        flag.code(stock.country),
        view_context.number_to_currency(stock.current_price&.to_f),
        view_context.number_to_currency(stock.price_change&.to_f),
        view_context.number_to_percentage(stock.price_change_pct&.to_f, precision: 2)
      ]
    end
  end

  def value_or_warning(div_suspended, value)
    div_suspended ? 'Sus.' : value
  end
end
