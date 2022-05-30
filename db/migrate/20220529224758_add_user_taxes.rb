# frozen_string_literal: true

class AddUserTaxes < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :taxes, :string
  end
end
