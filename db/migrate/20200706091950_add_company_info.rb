class AddCompanyInfo < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.references :stock
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
    end

    create_table :tags do |t|
      t.string :name
    end

    create_table :companies_tags do |t|
      t.references :company
      t.references :tag
    end
  end
end
