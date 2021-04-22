# frozen_string_literal: true

class AddPositionStopLoss < ActiveRecord::Migration[6.0]
  def change
    add_column :positions, :stop_loss_base, :decimal, precision: 10, scale: 2
    add_column :positions, :stop_loss, :decimal, precision: 10, scale: 2
    add_column :positions, :stop_loss_pct, :decimal, precision: 10, scale: 2

    add_column :positions, :stop_loss_value, :decimal, precision: 10, scale: 2
    add_column :positions, :stop_loss_gain_loss, :decimal, precision: 10, scale: 2
    add_column :positions, :stop_loss_gain_loss_pct, :decimal, precision: 10, scale: 2

    add_column :positions, :remind_at, :datetime
  end
end
