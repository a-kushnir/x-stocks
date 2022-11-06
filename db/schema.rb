# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_11_06_040001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configs", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_configs_on_key", unique: true
  end

  create_table "dividends", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.date "declaration_date"
    t.date "ex_dividend_date"
    t.date "record_date"
    t.date "pay_date"
    t.string "dividend_type", limit: 16
    t.string "currency", limit: 3
    t.decimal "amount", precision: 12, scale: 4
    t.integer "frequency"
    t.datetime "created_at", null: false
    t.index ["stock_id", "pay_date"], name: "index_dividends_on_stock_id_and_pay_date"
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "region", null: false
    t.string "iexapis_code"
    t.string "webull_code"
    t.string "finnhub_code"
    t.string "tradingview_code"
    t.string "dividend_code"
    t.datetime "created_at", null: false
  end

  create_table "financials", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.string "cik"
    t.date "start_date"
    t.date "end_date"
    t.integer "fiscal_year"
    t.string "fiscal_period", limit: 2
    t.bigint "common_stock_shares_outstanding"
    t.datetime "created_at", null: false
    t.index ["stock_id", "end_date"], name: "index_financials_on_stock_id_and_end_date"
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.decimal "shares", precision: 12, scale: 4
    t.decimal "average_price", precision: 10, scale: 2
    t.decimal "total_cost", precision: 10, scale: 2
    t.decimal "market_price", precision: 10, scale: 2
    t.decimal "market_value", precision: 10, scale: 2
    t.decimal "gain_loss", precision: 10, scale: 2
    t.decimal "gain_loss_pct", precision: 10, scale: 2
    t.decimal "est_annual_dividend", precision: 12, scale: 4
    t.decimal "est_annual_income", precision: 12, scale: 4
    t.integer "metascore"
    t.string "metascore_details"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "stop_loss_base", precision: 10, scale: 2
    t.decimal "stop_loss", precision: 10, scale: 2
    t.decimal "stop_loss_pct", precision: 10, scale: 2
    t.decimal "stop_loss_value", precision: 10, scale: 2
    t.decimal "stop_loss_gain_loss", precision: 10, scale: 2
    t.decimal "stop_loss_gain_loss_pct", precision: 10, scale: 2
    t.datetime "remind_at"
    t.index ["stock_id"], name: "index_positions_on_stock_id"
    t.index ["updated_at"], name: "index_positions_on_updated_at"
    t.index ["user_id", "stock_id"], name: "index_positions_on_user_id_and_stock_id", unique: true
    t.index ["user_id"], name: "index_positions_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "locked_at"
    t.datetime "last_run_at"
    t.string "error"
    t.string "log"
    t.string "file_name"
    t.string "file_type"
    t.string "file_content"
    t.index ["key"], name: "index_services_on_key", unique: true
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol", null: false
    t.bigint "exchange_id"
    t.string "company_name"
    t.string "industry"
    t.string "website"
    t.text "description"
    t.string "ceo"
    t.string "security_name"
    t.string "issue_type"
    t.string "sector"
    t.integer "primary_sic_code"
    t.integer "employees"
    t.string "address"
    t.string "address2"
    t.string "state"
    t.string "city"
    t.string "zip"
    t.string "country"
    t.string "phone"
    t.date "ipo"
    t.string "peers"
    t.decimal "outstanding_shares", precision: 16
    t.decimal "market_capitalization", precision: 20
    t.decimal "current_price", precision: 10, scale: 2
    t.decimal "prev_close_price", precision: 10, scale: 2
    t.decimal "open_price", precision: 10, scale: 2
    t.decimal "day_low_price", precision: 10, scale: 2
    t.decimal "day_high_price", precision: 10, scale: 2
    t.decimal "price_change", precision: 10, scale: 2
    t.decimal "price_change_pct", precision: 10, scale: 2
    t.decimal "week_52_high", precision: 10, scale: 2
    t.date "week_52_high_date"
    t.decimal "week_52_low", precision: 10, scale: 2
    t.date "week_52_low_date"
    t.integer "dividend_frequency_num"
    t.decimal "dividend_growth_3y", precision: 12, scale: 4
    t.integer "dividend_growth_years"
    t.date "next_div_ex_date"
    t.date "next_div_payment_date"
    t.decimal "next_div_amount", precision: 12, scale: 4
    t.decimal "est_annual_dividend", precision: 12, scale: 4
    t.decimal "est_annual_dividend_pct", precision: 10, scale: 2
    t.decimal "dividend_growth_5y", precision: 12, scale: 4
    t.decimal "payout_ratio", precision: 10, scale: 2
    t.decimal "eps_ttm", precision: 12, scale: 4
    t.decimal "eps_growth_3y", precision: 12, scale: 4
    t.decimal "eps_growth_5y", precision: 12, scale: 4
    t.decimal "pe_ratio_ttm", precision: 12, scale: 4
    t.string "earnings"
    t.date "next_earnings_date"
    t.string "next_earnings_hour"
    t.decimal "next_earnings_est_eps", precision: 12, scale: 4
    t.string "next_earnings_details"
    t.decimal "yahoo_beta", precision: 10, scale: 6
    t.decimal "yahoo_rec", precision: 5, scale: 2
    t.string "yahoo_rec_details"
    t.integer "yahoo_discount"
    t.decimal "finnhub_beta", precision: 10, scale: 6
    t.string "finnhub_price_target"
    t.decimal "finnhub_rec", precision: 5, scale: 2
    t.string "finnhub_rec_details"
    t.decimal "dividend_rating", precision: 5, scale: 2
    t.boolean "sp500"
    t.boolean "nasdaq100"
    t.boolean "dowjones"
    t.integer "metascore"
    t.string "metascore_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "yahoo_price_target"
    t.string "financials_yearly"
    t.string "financials_quarterly"
    t.decimal "yahoo_fair_price", precision: 10, scale: 2
    t.string "yahoo_sector"
    t.integer "yahoo_short_direction", limit: 2
    t.integer "yahoo_medium_direction", limit: 2
    t.integer "yahoo_long_direction", limit: 2
    t.text "yahoo_short_outlook"
    t.text "yahoo_medium_outlook"
    t.text "yahoo_long_outlook"
    t.decimal "yahoo_support", precision: 10, scale: 4
    t.decimal "yahoo_resistance", precision: 10, scale: 4
    t.decimal "yahoo_stop_loss", precision: 10, scale: 4
    t.string "taxes"
    t.decimal "expense_ratio", precision: 5, scale: 2
    t.string "segment"
    t.bigint "next_dividend_id"
    t.index ["exchange_id"], name: "index_stocks_on_exchange_id"
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
    t.index ["updated_at"], name: "index_stocks_on_updated_at"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.index ["key", "name", "stock_id"], name: "index_tags_on_key_and_name_and_stock_id", unique: true
    t.index ["stock_id"], name: "index_tags_on_stock_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.string "taxes"
    t.boolean "dividend_notifications"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "watchlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "symbols"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "positions", "stocks"
  add_foreign_key "positions", "users"
  add_foreign_key "stocks", "exchanges"
  add_foreign_key "tags", "stocks"
end
