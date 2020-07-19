class AlterTables < ActiveRecord::Migration[6.0]
  def change
    create_table :services do |t|
      t.string :key, null: false
      t.datetime :locked_at
      t.datetime :last_run_at
      t.string :error
      t.string :log

      t.index :key, unique: true
    end

    add_column :stocks, :dividend_growth_3y, :decimal, precision: 12, scale: 4
    add_column :stocks, :dividend_growth_years, :decimal, precision: 12, scale: 4

    add_column :positions, :metascore, :integer
    add_column :positions, :metascore_details, :string

    reversible do |dir|
      dir.up do
        Config.delete_all
      end
    end

  end
end
