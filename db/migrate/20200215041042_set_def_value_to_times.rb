class SetDefValueToTimes < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :time_started, :integer, :default => 0
    change_column :users, :time_submitted, :integer, :default => 0
  end
end
