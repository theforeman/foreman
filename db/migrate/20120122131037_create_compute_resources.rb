class CreateComputeResources < ActiveRecord::Migration
  def self.up
    create_table :compute_resources do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :user
      t.string :password
      t.string :uuid
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :compute_resources
  end
end
