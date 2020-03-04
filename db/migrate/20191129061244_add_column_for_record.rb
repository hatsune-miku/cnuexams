class AddColumnForRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :records, :exam_id, :integer
  end
end
