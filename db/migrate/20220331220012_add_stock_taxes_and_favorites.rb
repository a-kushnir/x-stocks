# frozen_string_literal: true

class AddStockTaxesAndFavorites < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :taxes, :string
    add_column :users, :favorites, :string

    reversible do |dir|
      dir.up do
        update_stocks
      end
    end
  end

  def update_stocks
    XStocks::AR::Stock.all.each do |stock|
      if foreign?(stock)
        stock.taxes ||= [:foreign_tax]
        stock.save!
      end
    end
  end

  def foreign?(stock)
    stock.country.present? && CountryFlag.new.code(stock.country) != 'US'
  end
end
