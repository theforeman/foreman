class CreateRoles  < ActiveRecord::Migration
  def self.up
    add_column :users, :role_id, :integer
    create_table "roles", :force => true do |t|
      t.column "name",        :string,  :limit => 30
      t.column "builtin",     :integer
      t.column "permissions", :text
    end

    create_table :user_roles do |t|
      t.column :user_id, :integer
      t.column :role_id, :integer
      t.columm :inherited_from, :integer
    end

  end

  def self.down
    drop_table :user_roles
    drop_table :roles
    remove_column :users, :role_id
  end
end
