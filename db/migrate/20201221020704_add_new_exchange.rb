# frozen_string_literal: true

class AddNewExchange < ActiveRecord::Migration[6.0]
  def change
    exchanges = [
      {
        name: 'NYSE',
        code: 'MKT',
        region: 'United States',
        iexapis_code: 'NYSE MKT LLC',
        webull_code: 'AMEX',
        finnhub_code: 'NYSE MKT LLC',
        tradingview_code: 'AMEX',
        dividend_code: 'AMEX'
      }
    ]

    XStocks::AR::Exchange.create!(exchanges)
  end
end
