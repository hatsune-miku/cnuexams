class AddLimit < ActiveRecord::Migration[5.1]
  def change
    add_column :users, 'last_login', :integer
    add_column :users, 'login_count', :integer
  end
end
