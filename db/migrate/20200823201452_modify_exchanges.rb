class ModifyExchanges < ActiveRecord::Migration[6.0]
  def up
    add_column :exchanges, :iexapis_code, :string, null: true
    add_column :exchanges, :webull_code, :string, null: true
    add_column :exchanges, :finnhub_code, :string, null: true
    add_column :exchanges, :tradingview_code, :string, null: true
    add_column :exchanges, :dividend_code, :string, null: true
    rename_column :exchanges, :short_name, :code

    Exchange.find_by(code: 'NASDAQ')
        .update(iexapis_code: 'NASDAQ', webull_code: 'nasdaq', finnhub_code: 'NASDAQ NMS - GLOBAL MARKET', tradingview_code: 'NASDAQ', dividend_code: 'NASDAQ')

    Exchange.find_by(code: 'NYSE')
        .update(iexapis_code: 'New York Stock Exchange', webull_code: 'nyse', finnhub_code: 'NEW YORK STOCK EXCHANGE, INC.', tradingview_code: 'NYSE', dividend_code: 'NYSE')

    Exchange.find_by(code: 'AMEX')
        .update(iexapis_code: 'NYSE Arca', webull_code: 'nysearca', finnhub_code: nil, tradingview_code: 'AMEX', dividend_code: 'AMEX')

    Exchange.find_by(code: 'TSX')
        .update(iexapis_code: 'US OTC', webull_code: 'otcmkts', finnhub_code: 'OTC MARKETS', tradingview_code: 'OTC', dividend_code: 'OTC')

    Exchange.create!({name: 'Bats Global Markets', code: 'BATS', region: 'United States',
                iexapis_code: nil, webull_code: 'amex', finnhub_code: 'BATS EXCHANGE', tradingview_code: 'AMEX', dividend_code: 'NASDAQ'})
  end

  def down
    Exchange.find_by(code: 'BATS').destroy

    remove_column :exchanges, :iexapis_code
    remove_column :exchanges, :webull_code
    remove_column :exchanges, :finnhub_code
    remove_column :exchanges, :tradingview_code
    remove_column :exchanges, :dividend_code
    rename_column :exchanges, :code, :short_name
  end
end
