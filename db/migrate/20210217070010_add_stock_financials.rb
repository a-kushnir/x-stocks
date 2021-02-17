# frozen_string_literal: true

class AddStockFinancials < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :financials_yearly, :string
    add_column :stocks, :financials_quarterly, :string
  end
end
