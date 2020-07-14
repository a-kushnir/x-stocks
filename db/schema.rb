# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_06_000000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configs", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_configs_on_key", unique: true
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name", null: false
    t.string "region", null: false
    t.datetime "created_at", null: false
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
    t.index ["stock_id"], name: "index_positions_on_stock_id"
    t.index ["user_id", "stock_id"], name: "index_positions_on_user_id_and_stock_id", unique: true
    t.index ["user_id"], name: "index_positions_on_user_id"
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
    t.string "logo"
    t.string "peers"
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
    t.string "dividend_details"
    t.string "dividend_frequency"
    t.integer "dividend_frequency_num"
    t.decimal "dividend_amount", precision: 12, scale: 4
    t.decimal "est_annual_dividend", precision: 12, scale: 4
    t.decimal "est_annual_dividend_pct", precision: 10, scale: 2
    t.decimal "dividend_growth_5y", precision: 12, scale: 4
    t.decimal "payout_ratio", precision: 10, scale: 2
    t.decimal "eps_ttm", precision: 12, scale: 4
    t.decimal "eps_growth_3y", precision: 12, scale: 4
    t.decimal "eps_growth_5y", precision: 12, scale: 4
    t.decimal "pe_ratio_ttm", precision: 12, scale: 4
    t.decimal "yahoo_beta", precision: 10, scale: 6
    t.decimal "yahoo_rec", precision: 5, scale: 2
    t.string "yahoo_rec_details"
    t.decimal "finnhub_beta", precision: 10, scale: 6
    t.string "finnhub_price_target"
    t.decimal "finnhub_rec", precision: 5, scale: 2
    t.string "finnhub_rec_details"
    t.string "earnings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id"], name: "index_stocks_on_exchange_id"
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "positions", "stocks"
  add_foreign_key "positions", "users"
  add_foreign_key "stocks", "exchanges"
  add_foreign_key "tags", "stocks"
end
