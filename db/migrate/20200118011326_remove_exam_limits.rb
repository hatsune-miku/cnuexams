class RemoveExamLimits < ActiveRecord::Migration[5.1]
  def change
    remove_column :exam_limits, :limit
    add_column :exams, :limit, :integer
    add_column :exams, :public, :boolean
  end
end
