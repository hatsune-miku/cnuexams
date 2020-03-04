class RenameTeacherNameToUsername < ActiveRecord::Migration[5.1]
  def change
    remove_column :members, :name
    add_column :members, :username, :string
  end
end
