class AddStocksTable < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.string :symbol, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
