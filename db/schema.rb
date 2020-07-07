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

ActiveRecord::Schema.define(version: 2020_07_07_060442) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.string "company_name"
    t.string "exchange"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_companies_on_stock_id"
  end

  create_table "companies_tags", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_companies_tags_on_company_id"
    t.index ["tag_id"], name: "index_companies_tags_on_tag_id"
  end

  create_table "company_peers", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.string "peer_symbol", null: false
    t.bigint "peer_stock_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["peer_stock_id"], name: "index_company_peers_on_peer_stock_id"
    t.index ["stock_id"], name: "index_company_peers_on_stock_id"
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.decimal "shares", precision: 12, scale: 4
    t.decimal "average_cost", precision: 12, scale: 4
    t.index ["stock_id"], name: "index_positions_on_stock_id"
    t.index ["user_id"], name: "index_positions_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

end
