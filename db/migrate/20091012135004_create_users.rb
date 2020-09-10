class CreateUsers < ActiveRecord::Migration[4.2]
  def up
    create_table :users do |t|
      t.string :login, :limit => 255
      t.string :firstname, :limit => 255
      t.string :lastname, :limit => 255
      t.string :mail, :limit => 255
      t.boolean :admin
      t.datetime :last_login_on
      t.integer :auth_source_id

      t.timestamps null: true
    end
  end

  def down
    drop_table :users
  end
end
