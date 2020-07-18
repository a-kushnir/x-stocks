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

    reversible do |dir|
      dir.up do
        Config.delete_all
      end
    end

  end
end
