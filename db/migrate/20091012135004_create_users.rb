class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :firstname
      t.string :lastname
      t.string :mail
      t.boolean :admin
      t.datetime :last_login_on
      t.integer :auth_source_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
