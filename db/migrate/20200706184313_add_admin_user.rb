class AddAdminUser < ActiveRecord::Migration[6.0]
  def up
    User.create!(email: 'admin@admin.com', password: 'admin!')
  end
end
