class CreateCustomcates < ActiveRecord::Migration[5.1]
  def change
    create_table :customcates do |t|
      t.string :name
      t.float :perportion

      t.timestamps
    end
    add_index :customcates, :name, unique: true
  end
end
