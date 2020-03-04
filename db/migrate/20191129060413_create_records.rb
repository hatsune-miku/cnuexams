class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :records do |t|
      t.string :username
      t.string :question_ids
      t.string :ans
      t.string :real_ans
      t.integer :time_elapsed

      t.timestamps
    end
  end
end
