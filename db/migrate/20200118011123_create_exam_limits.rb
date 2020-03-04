class CreateExamLimits < ActiveRecord::Migration[5.1]
  def change
    create_table :exam_limits do |t|
      t.string :username
      t.integer :exam_id
      t.integer :limit
      t.integer :current
      t.integer :locked_before

      t.timestamps
    end
  end
end
