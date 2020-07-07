class AddCompanyPeersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :company_peers do |t|
      t.references :stock, null: false
      t.string :peer_symbol, null: false
      t.references :peer_stock

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
