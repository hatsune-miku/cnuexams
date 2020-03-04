class RenameTypeToKind < ActiveRecord::Migration[5.1]
  def change
    rename_column :questionsnew, :type, :kind
    rename_column :institutes, :type, :kind
  end
end
