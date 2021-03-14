# frozen_string_literal: true

class AddFileToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :file_name, :string
    add_column :services, :file_type, :string
    add_column :services, :file_content, :string
  end
end
