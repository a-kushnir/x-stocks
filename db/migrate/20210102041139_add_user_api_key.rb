# frozen_string_literal: true

class AddUserAPIKey < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :api_key, :string
    add_index :users, :api_key, unique: true

    XStocks::AR::User.reset_column_information
    XStocks::AR::User.all.each do |user|
      XStocks::User.new.save(user) # Generates API tokens
    end
  end

  def down
    remove_column :users, :api_key
  end
end
