class RemoveLastScore < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :last_score
    remove_column :users, :passed_exams
  end
end
