class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :exchanges do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :region, null: false

      t.string :iexapis_code, null: true
      t.string :webull_code, null: true
      t.string :finnhub_code, null: true
      t.string :tradingview_code, null: true
      t.string :dividend_code, null: true

      t.datetime :created_at, null: false
    end

    create_table :stocks do |t|
      t.string :symbol, null: false
      t.references :exchange, foreign_key: true

      t.string :company_name
      t.string :industry
      t.string :website
      t.text :description
      t.string :ceo
      t.string :security_name
      t.string :issue_type
      t.string :sector
      t.integer :primary_sic_code
      t.integer :employees
      t.string :address
      t.string :address2
      t.string :state
      t.string :city
      t.string :zip
      t.string :country
      t.string :phone
      t.date :ipo
      t.string :logo
      t.string :peers

      t.decimal :outstanding_shares, precision: 16, scale: 0
      t.decimal :market_capitalization, precision: 20, scale: 0

      t.decimal :current_price, precision: 10, scale: 2
      t.decimal :prev_close_price, precision: 10, scale: 2
      t.decimal :open_price, precision: 10, scale: 2
      t.decimal :day_low_price, precision: 10, scale: 2
      t.decimal :day_high_price, precision: 10, scale: 2
      t.decimal :price_change, precision: 10, scale: 2
      t.decimal :price_change_pct, precision: 10, scale: 2

      t.decimal :week_52_high, precision: 10, scale: 2
      t.date :week_52_high_date
      t.decimal :week_52_low, precision: 10, scale: 2
      t.date :week_52_low_date

      t.string :dividend_details
      t.string :dividend_frequency
      t.integer :dividend_frequency_num
      t.decimal :dividend_growth_3y, precision: 12, scale: 4
      t.integer :dividend_growth_years
      t.date :next_div_ex_date
      t.date :next_div_payment_date
      t.decimal :next_div_amount, precision: 12, scale: 4

      t.decimal :dividend_amount, precision: 12, scale: 4
      t.decimal :est_annual_dividend, precision: 12, scale: 4
      t.decimal :est_annual_dividend_pct, precision: 10, scale: 2
      t.decimal :dividend_growth_5y, precision: 12, scale: 4
      t.decimal :payout_ratio, precision: 10, scale: 2

      t.decimal :eps_ttm, precision: 12, scale: 4
      t.decimal :eps_growth_3y, precision: 12, scale: 4
      t.decimal :eps_growth_5y, precision: 12, scale: 4
      t.decimal :pe_ratio_ttm, precision: 12, scale: 4

      t.string :earnings
      t.date :next_earnings_date
      t.string :next_earnings_hour
      t.decimal :next_earnings_est_eps, precision: 12, scale: 4
      t.string :next_earnings_details

      # Yahoo
      t.decimal :yahoo_beta, precision: 10, scale: 6
      t.decimal :yahoo_rec, precision: 5, scale: 2
      t.string :yahoo_rec_details
      t.integer :yahoo_discount, null: true

      # Finnhub
      t.decimal :finnhub_beta, precision: 10, scale: 6
      t.string :finnhub_price_target
      t.decimal :finnhub_rec, precision: 5, scale: 2
      t.string :finnhub_rec_details

      # Dividend.com
      t.decimal :dividend_rating, precision: 5, scale: 2

      # Slickcharts
      t.boolean :sp500
      t.boolean :nasdaq100
      t.boolean :dowjones

      t.integer :metascore
      t.string :metascore_details

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :symbol, unique: true
    end

    create_table :tags do |t|
      t.references :stock, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false

      t.datetime :created_at, null: false

      t.index [:key, :name, :stock_id], unique: true
    end

    create_table :positions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true

      t.decimal :shares, precision: 12, scale: 4
      t.decimal :average_price, precision: 10, scale: 2

      t.decimal :total_cost, precision: 10, scale: 2
      t.decimal :market_price, precision: 10, scale: 2
      t.decimal :market_value, precision: 10, scale: 2
      t.decimal :gain_loss, precision: 10, scale: 2
      t.decimal :gain_loss_pct, precision: 10, scale: 2

      t.decimal :est_annual_dividend, precision: 12, scale: 4
      t.decimal :est_annual_income, precision: 12, scale: 4

      t.integer :metascore
      t.string :metascore_details

      t.string :note

      t.index [:user_id, :stock_id], unique: true
    end

    create_table :configs do |t|
      t.string :key, null: false
      t.string :value

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :key, unique: true
    end

    create_table :services do |t|
      t.string :key, null: false
      t.datetime :locked_at
      t.datetime :last_run_at
      t.string :error
      t.string :log

      t.index :key, unique: true
    end

    reversible do |dir|
      dir.up do
        User.create!(email: 'admin@admin.com', password: 'admin!')

        Exchange.create!({
          name: 'Nasdaq',
          code: 'NASDAQ',
          region: 'United States',
          iexapis_code: 'NASDAQ',
          webull_code: 'nasdaq',
          finnhub_code: 'NASDAQ NMS - GLOBAL MARKET',
          tradingview_code: 'NASDAQ',
          dividend_code: 'NASDAQ'
        })

        Exchange.create!({
          name: 'New York Stock Exchange',
          code: 'NYSE',
          region: 'United States',
          iexapis_code: 'New York Stock Exchange',
          webull_code: 'nyse',
          finnhub_code: 'NEW YORK STOCK EXCHANGE, INC.',
          tradingview_code: 'NYSE',
          dividend_code: 'NYSE'
        })

        Exchange.create!({
          name: 'NYSE Arca',
          code: 'AMEX',
          region: 'United States',
          iexapis_code: 'NYSE Arca',
          webull_code: 'nysearca',
          finnhub_code: nil,
          tradingview_code: 'AMEX',
          dividend_code: 'AMEX'
        })

        Exchange.find_by({
          name: 'Toronto Stock Exchange',
          code: 'TSX',
          region: 'Canada',
          iexapis_code: 'US OTC',
          webull_code: 'otcmkts',
          finnhub_code: 'OTC MARKETS',
          tradingview_code: 'OTC',
          dividend_code: 'OTC'
        })

        Exchange.create!({
          name: 'Bats Global Markets',
          code: 'BATS',
          region: 'United States',
          iexapis_code: nil,
          webull_code: 'amex',
          finnhub_code: 'BATS EXCHANGE',
          tradingview_code: 'AMEX',
          dividend_code: 'NASDAQ'
        })
      end
    end
  end
end
