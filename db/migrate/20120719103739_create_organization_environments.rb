class CreateOrganizationEnvironments < ActiveRecord::Migration
  def self.up
    create_table :organization_environments do |t|
      t.integer :organization_id
      t.integer :environment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_environments
  end
end
