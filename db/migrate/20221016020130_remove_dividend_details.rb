# frozen_string_literal: true

class RemoveDividendDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :stocks, :dividend_details, :string
    remove_column :stocks, :dividend_frequency, :string
  end
end
