class AddCompanyInfo < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.references :stock, null: false
      t.string :company_name
      t.string :exchange
      t.string :industry
      t.string :website
      t.text :description
      t.string :ceo
      t.string :security_name
      t.string :issue_type
      t.string :sector
      t.integer :primary_sic_code
      t.integer :employees
      t.string :address
      t.string :address2
      t.string :state
      t.string :city
      t.string :zip
      t.string :country
      t.string :phone
      t.date :ipo
      t.string :logo

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    create_table :tags do |t|
      t.string :name, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    create_table :companies_tags do |t|
      t.references :company, null: false
      t.references :tag, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
