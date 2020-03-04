class MoveLastLoginToExamLimit < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :last_login
    add_column :exam_limits, :last_login, :integer
  end
end
