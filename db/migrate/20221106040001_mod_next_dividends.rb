# frozen_string_literal: true

class ModNextDividends < ActiveRecord::Migration[7.0]
  def change
    remove_column :stocks, :dividend_amount, :decimal, precision: 12, scale: 4
    add_column :stocks, :next_dividend_id, :bigint
  end
end
