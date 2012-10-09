class CreateTaxonomyUsers < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_users, :id => false do |t|
      t.integer :taxonomy_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_users
  end
end
