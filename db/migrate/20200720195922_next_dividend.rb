class NextDividend < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :next_div_ex_date, :date
    add_column :stocks, :next_div_payment_date, :date
    add_column :stocks, :next_div_amount, :decimal, precision: 12, scale: 4
  end
end
