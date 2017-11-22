class CreateRoles < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :role_id, :integer
    create_table "roles", :force => true do |t|
      t.string "name", :limit => 30
      t.integer "builtin"
      t.text "permissions"
    end

    create_table :user_roles do |t|
      t.integer :user_id
      t.integer :role_id
      t.integer :inherited_from
    end
  end

  def down
    drop_table :user_roles
    drop_table :roles
    remove_column :users, :role_id
  end
end
