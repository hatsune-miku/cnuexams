class AddHitMissToRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :records, :hit, :integer
    add_column :records, :miss, :integer
  end
end
