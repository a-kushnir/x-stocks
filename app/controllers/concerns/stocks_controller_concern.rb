# frozen_string_literal: true

# Shared module for controllers with Stock tables
module StocksControllerConcern
  extend ActiveSupport::Concern

  def stock_table
    table = DataTable::Table.new(params)

    table.init_columns do |columns|
      # Stock
      columns << DataTable::Column.new(code: 'smb', label: t('stocks.columns.symbol'), formatter: 'stock_link', sorting: 'stocks.symbol', default: true)
      columns << DataTable::Column.new(code: 'cmp', label: t('stocks.columns.company'), formatter: 'string', sorting: 'stocks.company_name', default: true)
      columns << DataTable::Column.new(code: 'cnt', label: t('stocks.columns.country'), formatter: 'string', align: 'center', sorting: 'stocks.country')
      columns << DataTable::Column.new(code: 'prc', label: t('stocks.columns.price'), formatter: 'currency', default: true)
      columns << DataTable::Column.new(code: 'prd', label: t('stocks.columns.change'), formatter: 'currency_delta', default: true)
      columns << DataTable::Column.new(code: 'prp', label: t('stocks.columns.change_pct'), formatter: 'percent_delta2', default: true)
      columns << DataTable::Column.new(code: 'wkr', label: t('stocks.columns.52wk_range'), formatter: 'price_range')
      columns << DataTable::Column.new(code: 'frv', label: t('stocks.columns.fair_value'), formatter: 'percent_delta0', sorting: 'stocks.yahoo_discount', default: true)
      columns << DataTable::Column.new(code: 'srg', label: t('stocks.columns.short_term'), formatter: 'direction', sorting: 'stocks.yahoo_short_direction')
      columns << DataTable::Column.new(code: 'mrg', label: t('stocks.columns.mid_term'), formatter: 'direction', sorting: 'stocks.yahoo_medium_direction')
      columns << DataTable::Column.new(code: 'lrg', label: t('stocks.columns.long_term'), formatter: 'direction', sorting: 'stocks.yahoo_long_direction')
      columns << DataTable::Column.new(code: 'dvf', label: t('stocks.columns.div_frequency'), formatter: 'string', align: 'right', sorting: 'stocks.dividend_frequency_num')
      columns << DataTable::Column.new(code: 'ndv', label: t('stocks.columns.next_div'), formatter: 'currency_or_warning4', sorting: 'stocks.next_div_amount')
      columns << DataTable::Column.new(code: 'ead', label: t('stocks.columns.est_annual_div'), formatter: 'currency_or_warning', default: true)
      columns << DataTable::Column.new(code: 'eyp', label: t('stocks.columns.est_annual_div'), formatter: 'percent_or_warning2', default: true)
      columns << DataTable::Column.new(code: 'dcp', label: t('stocks.columns.div_change_pct'), formatter: 'percent_delta1')
      columns << DataTable::Column.new(code: 'per', label: t('stocks.columns.pe_ratio'), formatter: 'number2', sorting: 'stocks.pe_ratio_ttm')
      columns << DataTable::Column.new(code: 'ptp', label: t('stocks.columns.payout_pct'), formatter: 'percent2', sorting: 'stocks.payout_ratio')
      columns << DataTable::Column.new(code: 'cap', label: t('stocks.columns.market_cap'), formatter: 'big_currency', sorting: 'stocks.market_capitalization')
      columns << DataTable::Column.new(code: 'yrc', label: t('stocks.columns.yahoo_rec'), formatter: 'recommendation', sorting: 'stocks.yahoo_rec')
      columns << DataTable::Column.new(code: 'frc', label: t('stocks.columns.finnhub_rec'), formatter: 'recommendation', sorting: 'stocks.finnhub_rec')
      columns << DataTable::Column.new(code: 'dsf', label: t('stocks.columns.div_safety'), formatter: 'safety_badge', sorting: 'stocks.dividend_rating')
      columns << DataTable::Column.new(code: 'exd', label: t('stocks.columns.ex_dividend_date'), formatter: 'future_date', sorting: 'stocks.next_div_ex_date')
    end
  end

  def stock_table_row(stock)
    flag = CountryFlag.new
    stock = XStocks::Stock.new(stock)
    div_suspended = stock.div_suspended?
    [
      stock.symbol,
      stock.company_name,
      flag.code(stock.country),
      stock.current_price&.to_f,
      stock.price_change&.to_f,
      stock.price_change_pct&.to_f,
      stock.price_range,
      stock.yahoo_discount&.to_f,
      stock.yahoo_short_direction,
      stock.yahoo_medium_direction,
      stock.yahoo_long_direction,
      XStocks::Dividends::Frequency.humanize(stock.dividend_frequency_num),
      stock.next_div_amount&.to_f,
      value_or_warning(div_suspended, stock.est_annual_dividend&.to_f),
      value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
      stock.div_change_pct&.round(1),
      stock.pe_ratio_ttm&.to_f&.round(2),
      stock.payout_ratio&.to_f,
      stock.market_capitalization&.to_f,
      stock.yahoo_rec&.to_f,
      stock.finnhub_rec&.to_f,
      stock.dividend_rating&.to_f,
      stock.prev_month_ex_date? ? stock.next_div_ex_date : nil
    ]
  end

  def value_or_warning(div_suspended, value)
    div_suspended ? 'Sus.' : value
  end
end
