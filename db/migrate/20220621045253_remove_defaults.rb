# frozen_string_literal: true

class RemoveDefaults < ActiveRecord::Migration[7.0]
  def up
    change_column_default(:positions, :created_at, nil)
    change_column_default(:positions, :updated_at, nil)
    remove_column(:users, :favorites)
  end
end
