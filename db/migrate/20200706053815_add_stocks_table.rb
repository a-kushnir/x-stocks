class AddStocksTable < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.string :symbol
    end
  end
end
