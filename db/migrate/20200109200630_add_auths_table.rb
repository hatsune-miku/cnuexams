class AddAuthsTable < ActiveRecord::Migration[5.1]
  def change
    unless table_exists? 'auths'
      create_table "auths", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
        t.string "authorizer"
        t.integer "authorizee"
        t.string "auth_code"
        t.integer "remaining"
      end
    end
  end
end
