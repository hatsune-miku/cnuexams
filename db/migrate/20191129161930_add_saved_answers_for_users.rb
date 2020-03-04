class AddSavedAnswersForUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :saved_answers, :string
  end
end
