class AddSessionIdToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :session_id, :string
  end
end
