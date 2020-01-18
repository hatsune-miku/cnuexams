class SetDefaultExamLimit2 < ActiveRecord::Migration[5.1]
  def change
    change_column :exams, :limit, :integer, :default => 0
    change_column :exams, :public, :boolean, :default => 0
  end
end
