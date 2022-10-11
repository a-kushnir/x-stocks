# frozen_string_literal: true

class AddNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :dividend_notifications, :boolean
  end
end
