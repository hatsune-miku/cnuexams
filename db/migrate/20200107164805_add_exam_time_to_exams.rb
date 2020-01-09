class AddExamTimeToExams < ActiveRecord::Migration[5.1]
  def change
    add_column :exams, :time_limit, :integer
    p 'miku!'
  end
end
