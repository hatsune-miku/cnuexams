class AddLabelToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :label, :string
  end
end
