class CreatePreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :preferences do |t|
      t.string :name, limit: 64
      t.string :value

      t.timestamps
    end
  end
end
