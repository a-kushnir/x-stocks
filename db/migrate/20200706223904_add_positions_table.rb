class AddPositionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :positions do |t|
      t.references :user, null: false
      t.references :stock, null: false

      t.decimal :shares, precision: 12, scale: 4
      t.decimal :average_cost, precision: 12, scale: 4
    end
  end
end
