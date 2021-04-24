# frozen_string_literal: true

class AddYahooTechnicals < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :yahoo_sector, :string
    add_column :stocks, :yahoo_short_direction, :integer, limit: 1
    add_column :stocks, :yahoo_medium_direction, :integer, limit: 1
    add_column :stocks, :yahoo_long_direction, :integer, limit: 1
    add_column :stocks, :yahoo_short_outlook, :text
    add_column :stocks, :yahoo_medium_outlook, :text
    add_column :stocks, :yahoo_long_outlook, :text
    add_column :stocks, :yahoo_support, :decimal, precision: 10, scale: 4
    add_column :stocks, :yahoo_resistance, :decimal, precision: 10, scale: 4
    add_column :stocks, :yahoo_stop_loss, :decimal, precision: 10, scale: 4
  end
end
