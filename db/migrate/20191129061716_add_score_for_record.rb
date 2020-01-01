class AddScoreForRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :records, :score, :float
  end
end
