class CreateSshKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :ssh_keys do |t|
      t.string :name, :limit => 255
      t.text :key
      t.string :fingerprint
      t.integer :user_id
      t.integer :length

      t.timestamps :null => false
    end
  end
end
