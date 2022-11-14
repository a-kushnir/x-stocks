# frozen_string_literal: true

class AddStockSignals < ActiveRecord::Migration[7.0]
  def change
    create_table :signals do |t|
      t.references :stock, null: false, index: false
      t.datetime :timestamp
      t.string :detection_method
      t.string :value
      t.datetime :created_at, null: false
      t.index %i[timestamp]
    end
  end
end
