class AddPositionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :positions do |t|
      t.references :user
      t.references :stock

      t.decimal :shares, precision: 12, scale: 4
      t.decimal :average_cost, precision: 12, scale: 4
    end
  end
end
