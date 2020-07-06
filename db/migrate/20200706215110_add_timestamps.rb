class AddTimestamps < ActiveRecord::Migration[6.0]
  def change
    Stock.delete_all
    Stock.connection.execute('ALTER SEQUENCE stocks_id_seq RESTART WITH 1')
    Company.delete_all
    Company.connection.execute('ALTER SEQUENCE companies_id_seq RESTART WITH 1')
    CompaniesTag.delete_all
    CompaniesTag.connection.execute('ALTER SEQUENCE companies_tags_id_seq RESTART WITH 1')
    Tag.delete_all
    Tag.connection.execute('ALTER SEQUENCE tags_id_seq RESTART WITH 1')

    add_column :stocks, :created_at, :datetime, null: false
    add_column :stocks, :updated_at, :datetime, null: false
    add_column :companies, :created_at, :datetime, null: false
    add_column :companies, :updated_at, :datetime, null: false
    add_column :companies_tags, :created_at, :datetime, null: false
    add_column :companies_tags, :updated_at, :datetime, null: false
    add_column :tags, :created_at, :datetime, null: false
    add_column :tags, :updated_at, :datetime, null: false
  end
end
