# frozen_string_literal: true

class AddDividendsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :dividends do |t|
      t.references :stock, null: false, index: false
      t.date :declaration_date
      t.date :ex_dividend_date
      t.date :record_date
      t.date :pay_date
      t.string :dividend_type, limit: 16
      t.string :currency, limit: 3
      t.decimal :amount, precision: 12, scale: 4
      t.integer :frequency
      t.datetime :created_at, null: false
      t.index %i[stock_id pay_date]
    end
  end
end
