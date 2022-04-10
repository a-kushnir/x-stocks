# frozen_string_literal: true

module Positions
  # Table representation of user portfolio positions
  class TableController < ApplicationController
    memorize_params :datatable_positions, only: [:index] do
      params.permit(:items, columns: [])
    end

    def index
      @table = table
      positions = XStocks::AR::Position.joins(:stock).with_user(current_user).with_shares
      positions = positions.reorder(@table.sort_column => @table.sort_direction)
      positions = positions.where('LOWER(stocks.symbol) like LOWER(:q) or LOWER(stocks.company_name) like LOWER(:q)', q: "%#{params[:q]}%") if params[:q].present?
      positions = positions.all
      return unless stale?(positions)

      @pagy, positions = pagy positions, items: @table.pagy_items

      rows, @summary = data(positions.to_a)
      @table.rows.concat(rows)
      @summary_row = [
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        @summary[:total_cost],
        @summary[:market_value],
        @summary[:today_return],
        @summary[:today_return_pct],
        @summary[:total_return],
        @summary[:total_return_pct],
        @summary[:next_div],
        @summary[:est_annual_div],
        100,
        nil,
        @summary[:stop_loss_value],
        @summary[:stop_loss_gain_loss],
        @summary[:stop_loss_gain_loss_pct],
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        @summary[:yield_on_value],
        nil,
        nil,
        nil,
        nil,
        nil,
        @summary[:dividend_rating],
        nil,
        nil
      ]

      @page_title = 'My Positions'
      @page_menu_item = :positions
    end

    private

    def table
      table = DataTable::Table.new(params)

      table.init_columns do |columns|
        # Stock
        columns << DataTable::Column.new(code: 'smb', label: 'Symbol', formatter: 'string', sorting: 'stocks.symbol', default: true)
        columns << DataTable::Column.new(code: 'cmp', label: 'Company', formatter: 'string', sorting: 'stocks.company_name', default: true)
        columns << DataTable::Column.new(code: 'cnt', label: 'Country', formatter: 'string', align: 'center', sorting: 'stocks.country')
        # Position
        columns << DataTable::Column.new(code: 'shr', label: 'Shares', formatter: 'number', align: 'right', sorting: 'positions.shares', default: true)
        columns << DataTable::Column.new(code: 'apr', label: 'Average Price', formatter: 'currency', align: 'right', sorting: 'positions.average_price', default: true)
        columns << DataTable::Column.new(code: 'mpr', label: 'Market Price', formatter: 'currency', align: 'right', sorting: 'positions.market_price', default: true)
        columns << DataTable::Column.new(code: 'cst', label: 'Total Cost', formatter: 'currency', align: 'right', sorting: 'positions.total_cost', default: true)
        columns << DataTable::Column.new(code: 'mvl', label: 'Market Value', formatter: 'currency', align: 'right', sorting: 'positions.market_value', default: true)
        columns << DataTable::Column.new(code: 'drc', label: "Today's Return", formatter: 'currency_delta', align: 'right')
        columns << DataTable::Column.new(code: 'drp', label: "Today's Return %", formatter: 'percent_delta2', align: 'right', sorting: 'stock.price_change_pct')
        columns << DataTable::Column.new(code: 'trc', label: 'Total Return', formatter: 'currency_delta', align: 'right', sorting: 'positions.gain_loss', default: true)
        columns << DataTable::Column.new(code: 'trp', label: 'Total Return %', formatter: 'percent_delta2', align: 'right', sorting: 'positions.gain_loss_pct', default: true)
        columns << DataTable::Column.new(code: 'ndv', label: 'Next Div.', formatter: 'currency', align: 'right', default: true)
        columns << DataTable::Column.new(code: 'adv', label: 'Annual Div.', formatter: 'currency', align: 'right', default: true)
        columns << DataTable::Column.new(code: 'dvr', label: 'Diversity %', formatter: 'percent2', align: 'right', sorting: 'positions.market_value')
        # Stop Loss
        columns << DataTable::Column.new(code: 'spp', label: 'Stop Price', formatter: 'currency', align: 'right')
        columns << DataTable::Column.new(code: 'ecr', label: 'Est. Credit', formatter: 'currency', align: 'right')
        columns << DataTable::Column.new(code: 'ert', label: 'Est. Return', formatter: 'currency_delta', align: 'right')
        columns << DataTable::Column.new(code: 'erp', label: 'Est. Return %', formatter: 'percent_delta2', align: 'right')
        # Stock
        columns << DataTable::Column.new(code: 'prc', label: 'Price', formatter: 'currency', align: 'right')
        columns << DataTable::Column.new(code: 'prd', label: 'Change', formatter: 'currency_delta', align: 'right')
        columns << DataTable::Column.new(code: 'prp', label: 'Change %', formatter: 'percent_delta2', align: 'right')
        columns << DataTable::Column.new(code: 'wkr', label: '52 Week Range', formatter: 'price_range')
        columns << DataTable::Column.new(code: 'frv', label: 'Fair Value', formatter: 'percent_delta0', align: 'right', sorting: 'stocks.yahoo_discount')
        # columns << { label: 'Short Term' }
        # columns << { label: 'Mid Term' }
        # columns << { label: 'Long Term' }
        # columns << { label: 'Div. Frequency' }
        # columns << { label: 'Est. Annual Div.' }
        # columns << { label: 'Est. Yield %' }
        # columns << { label: 'Div. Change %' }
        # columns << { label: 'P/E Ratio' }
        # columns << { label: 'Payout %' }
        # columns << { label: 'Yahoo Rec.' }
        # columns << { label: 'Finnhub Rec.' }
        # columns << { label: 'Div. Safety' }
        # columns << { label: 'Ex Date' }
        # columns << { label: 'Score', align: 'center' }
      end

      table
    end

    def data(positions)
      stocks = XStocks::Stock.find_all(id: positions.map(&:stock_id))
      @stocks_by_id = stocks.index_by(&:id)

      total_market_value = positions.sum(&:market_value)
      avg_dividend_rating = XStocks::Position::AvgDividendRating.new

      data = []
      positions.each do |position|
        stock = @stocks_by_id[position.stock_id]
        div_suspended = stock.div_suspended?
        avg_dividend_rating.add(stock.dividend_rating, div_suspended, position.market_value)

        data << row(stock, position, div_suspended, total_market_value)
      end

      summary = {
        dividend_rating: avg_dividend_rating.value
      }

      [data, summary(@stocks_by_id, positions, summary)]
    end

    def row(stock, position, div_suspended, total_market_value)
      diversity = position.market_value && total_market_value ? (position.market_value / total_market_value * 100).round(2) : nil
      flag = CountryFlag.new

      [
        # Stock
        view_context.link_to(stock.symbol, stock_url(stock.symbol), class: 'text-blue-500 no-underline inline-block w-full', target: '_top'),
        stock.company_name,
        flag.code(stock.country),
        # Position
        position.shares&.to_f,
        position.average_price&.to_f,
        position.market_price&.to_f,
        position.total_cost&.to_f,
        position.market_value&.to_f,
        stock.price_change && position.shares ? (stock.price_change * position.shares).to_f : nil,
        stock.price_change_pct&.to_f,
        position.gain_loss&.to_f,
        position.gain_loss_pct&.to_f,
        position.shares && stock.next_div_amount ? (position.shares * stock.next_div_amount)&.to_f : nil,
        position.est_annual_income&.to_f,
        diversity&.to_f,
        # Stop Loss
        position.stop_loss&.to_f,
        position.stop_loss_value&.to_f,
        position.stop_loss_gain_loss&.to_f,
        position.stop_loss_gain_loss_pct&.to_f,
        # Stock
        stock.current_price&.to_f,
        stock.price_change&.to_f,
        stock.price_change_pct&.to_f,
        stock.price_range,
        stock.yahoo_discount&.to_f,
        stock.yahoo_short_direction,
        stock.yahoo_medium_direction,
        stock.yahoo_long_direction,
        [stock.dividend_frequency&.titleize, stock.dividend_frequency_num],
        value_or_warning(div_suspended, stock.est_annual_dividend&.to_f),
        value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
        stock.div_change_pct&.round(1),
        stock.pe_ratio_ttm&.to_f&.round(2),
        stock.payout_ratio&.to_f,
        stock.yahoo_rec&.to_f,
        stock.finnhub_rec&.to_f,
        stock.dividend_rating&.to_f,
        stock.prev_month_ex_date? ? stock.next_div_ex_date : nil,
        [stock.metascore, stock.meta_score_details]
      ]
    end

    def value_or_warning(div_suspended, value)
      div_suspended ? 'Sus.' : value
    end

    def summary(stocks_by_id, positions, summary)
      total_cost = positions.map(&:total_cost).compact.sum || 0
      market_value = positions.map(&:market_value).compact.sum || 0

      today_return = positions.sum do |position|
        stock = stocks_by_id[position.stock_id]
        position.shares && stock&.price_change ? position.shares * stock.price_change : 0
      end

      today_return_pct = total_cost.positive? ? today_return / market_value * 100 : 0
      total_return = market_value - total_cost
      total_return_pct = total_cost.positive? ? total_return / total_cost * 100 : 0

      next_div = positions.sum do |position|
        stock = stocks_by_id[position.stock_id]
        position.shares && stock&.next_div_amount ? position.shares * stock.next_div_amount : 0
      end

      est_annual_div = positions.map(&:est_annual_income).compact.sum
      yield_on_value = market_value.positive? ? (est_annual_div / market_value) * 100 : 0

      stop_loss_positions = positions.select(&:stop_loss_value)
      stop_loss_value = stop_loss_positions.sum(&:stop_loss_value) || 0
      stop_loss_gain_loss = stop_loss_positions.sum(&:stop_loss_gain_loss) || 0
      stop_loss_market_value = stop_loss_positions.sum(&:market_value) || 0
      stop_loss_gain_loss_pct = stop_loss_market_value.positive? ? (stop_loss_gain_loss / stop_loss_market_value) * 100 : 0

      summary.merge({
                      total_cost: total_cost,
                      market_value: market_value,
                      today_return: today_return,
                      today_return_pct: today_return_pct,
                      total_return: total_return,
                      total_return_pct: total_return_pct,
                      next_div: next_div,
                      est_annual_div: est_annual_div,
                      yield_on_value: yield_on_value,
                      stop_loss_value: stop_loss_value,
                      stop_loss_gain_loss: stop_loss_gain_loss,
                      stop_loss_gain_loss_pct: stop_loss_gain_loss_pct
                    })
    end
  end
end
