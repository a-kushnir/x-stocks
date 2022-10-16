# frozen_string_literal: true

class RemoveStockLogo < ActiveRecord::Migration[7.0]
  def change
    remove_column :stocks, :logo, :string
  end
end
