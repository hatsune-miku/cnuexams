class CreateExamQuestionKinds < ActiveRecord::Migration[5.1]
  def change
    create_table :exam_question_kinds do |t|
      t.bigint :exam_id
      t.string :label
      t.float :proportion

      t.timestamps
    end
  end
end
