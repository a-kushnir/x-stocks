# frozen_string_literal: true

class AddEtfFields < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :expense_ratio, :decimal, precision: 5, scale: 2
    add_column :stocks, :segment, :string
  end
end
