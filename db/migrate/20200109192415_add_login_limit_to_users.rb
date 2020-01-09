class AddLoginLimitToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :login_count
    add_column :users, :login_count, :integer, :default => 0, :null => false
  end
end
