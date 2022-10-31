# frozen_string_literal: true

class AddFinancialsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :financials do |t|
      t.references :stock, null: false, index: false
      t.string :cik
      t.date :start_date
      t.date :end_date
      t.integer :fiscal_year
      t.string :fiscal_period, limit: 2
      t.bigint :common_stock_shares_outstanding
      t.datetime :created_at, null: false
      t.index %i[stock_id end_date]
    end
  end
end
