class FixAuths < ActiveRecord::Migration[5.1]
  def change
    change_column :auths, :authorizee, :string
    remove_column :auths, :id
  end
end
