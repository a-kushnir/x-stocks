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

ActiveRecord::Schema.define(version: 2020_07_06_091950) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.bigint "stock_id"
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
    t.index ["stock_id"], name: "index_companies_on_stock_id"
  end

  create_table "companies_tags", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "tag_id"
    t.index ["company_id"], name: "index_companies_tags_on_company_id"
    t.index ["tag_id"], name: "index_companies_tags_on_tag_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
  end

end
