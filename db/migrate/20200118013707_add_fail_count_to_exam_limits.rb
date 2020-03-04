class AddFailCountToExamLimits < ActiveRecord::Migration[5.1]
  def change
    add_column :exam_limits, :fail_count, :integer, :default => 0
  end
end
