class AddIdForInstitutes < ActiveRecord::Migration[5.1]
  def change
    execute 'alter table institutes drop primary key'
    execute 'alter table institutes add column id integer primary key auto_increment'
  end
end
