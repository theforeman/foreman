class CreateOrganizationUsers < ActiveRecord::Migration
  def self.up
    create_table :organization_users do |t|
      t.integer :organization_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_users
  end
end
