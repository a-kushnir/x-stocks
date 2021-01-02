class AddUserAPIKey < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :api_key, :string
    add_index :users, :api_key, unique: true

    User.reset_column_information
    User.all.each(&:save) # Generates API tokens
  end

  def down
    remove_column :users, :api_key
  end
end
