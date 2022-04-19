# frozen_string_literal: true

class UpdateConfigTable < ActiveRecord::Migration[7.0]
  def up
    XStocks::AR::Config.delete_all
    change_column :configs, :value, :text
  end

  def down
    XStocks::AR::Config.delete_all
    change_column :configs, :value, :string
  end
end
