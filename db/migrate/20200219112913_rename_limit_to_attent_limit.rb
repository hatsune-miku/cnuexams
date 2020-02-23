class RenameLimitToAttentLimit < ActiveRecord::Migration[5.1]
  def change
    rename_column :exams, :limit, :attend_limit
  end
end
