# frozen_string_literal: true

class AddWatchlists < ActiveRecord::Migration[7.0]
  def change
    create_table :watchlists do |t|
      t.references :user, null: false

      t.string :name
      t.text :symbols

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
