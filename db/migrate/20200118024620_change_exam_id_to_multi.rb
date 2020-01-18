class ChangeExamIdToMulti < ActiveRecord::Migration[5.1]
  def change
    change_column :questions, :exam, :string
  end
end
