class SetDefaultExamLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :exams, :limit, :integer, :default => 0
  end
end
