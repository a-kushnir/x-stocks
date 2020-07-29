class AddNextEarnings < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :next_earnings_date, :date
    add_column :stocks, :next_earnings_hour, :string
    add_column :stocks, :next_earnings_est_eps, :decimal, precision: 12, scale: 4
    add_column :stocks, :next_earnings_details, :string
  end
end
