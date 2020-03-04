class AdaptInstitute < ActiveRecord::Migration[5.1]
  def change
    add_column :institutes, :created_at, :datetime
    add_column :institutes, :updated_at, :datetime
  end
end
