class AddDividendsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_dividends do |t|
      t.references :stock, null: false
      t.datetime :ex_date
      t.datetime :payment_date
      t.datetime :record_date
      t.datetime :declared_date
      t.decimal :amount, precision: 12, scale: 4
      t.string :flag
      t.string :currency
      t.string :description
      t.string :frequency
      t.datetime :updated_at, null: false
    end
  end
end
