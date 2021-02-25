# frozen_string_literal: true

class AddPositionUpdateAt < ActiveRecord::Migration[6.0]
  def change
    add_column :positions, :created_at, :datetime, null: false, default: '2020-01-01'
    add_column :positions, :updated_at, :datetime, null: false, default: '2020-01-01'
    add_index :positions, :updated_at
    add_index :stocks, :updated_at
  end
end
