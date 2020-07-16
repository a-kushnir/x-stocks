class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :exchanges do |t|
      t.string :name, null: false
      t.string :short_name, null: false
      t.string :region, null: false

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
      t.decimal :dividend_amount, precision: 12, scale: 4
      t.decimal :est_annual_dividend, precision: 12, scale: 4
      t.decimal :est_annual_dividend_pct, precision: 10, scale: 2
      t.decimal :dividend_growth_5y, precision: 12, scale: 4
      t.decimal :payout_ratio, precision: 10, scale: 2

      t.decimal :eps_ttm, precision: 12, scale: 4
      t.decimal :eps_growth_3y, precision: 12, scale: 4
      t.decimal :eps_growth_5y, precision: 12, scale: 4
      t.decimal :pe_ratio_ttm, precision: 12, scale: 4

      # Yahoo
      t.decimal :yahoo_beta, precision: 10, scale: 6
      t.decimal :yahoo_rec, precision: 5, scale: 2
      t.string :yahoo_rec_details

      # Finnhub
      t.decimal :finnhub_beta, precision: 10, scale: 6
      t.string :finnhub_price_target
      t.decimal :finnhub_rec, precision: 5, scale: 2
      t.string :finnhub_rec_details

      # Dividend.com
      t.decimal :dividend_rating, precision: 5, scale: 2

      t.string :earnings

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

      t.index [:user_id, :stock_id], unique: true
    end

    create_table :configs do |t|
      t.string :key, null: false
      t.string :value

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :key, unique: true
    end

    reversible do |dir|
      dir.up do
        Exchange.create!({name: 'Nasdaq', short_name: 'NASDAQ', region: 'United States'})
        Exchange.create!({name: 'New York Stock Exchange', short_name: 'NYSE', region: 'United States'})
        Exchange.create!({name: 'NYSE Arca', short_name: 'AMEX', region: 'United States'})
        Exchange.create!({name: 'Toronto Stock Exchange', short_name: 'TSX', region: 'Canada'})
      end
    end
  end
end
