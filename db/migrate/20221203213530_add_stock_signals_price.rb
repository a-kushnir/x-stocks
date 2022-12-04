# frozen_string_literal: true

class AddStockSignalsPrice < ActiveRecord::Migration[7.0]
  def change
    add_column :signals, :price, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
