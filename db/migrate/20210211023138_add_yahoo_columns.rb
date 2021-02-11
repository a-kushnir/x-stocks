# frozen_string_literal: true

class AddYahooColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :yahoo_price_target, :string
  end
end
