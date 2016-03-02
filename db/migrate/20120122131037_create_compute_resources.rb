class CreateComputeResources < ActiveRecord::Migration
  def up
    create_table :compute_resources do |t|
      t.string :name, :limit => 255
      t.string :description, :limit => 255
      t.string :url, :limit => 255
      t.string :user, :limit => 255
      t.string :password, :limit => 255
      t.string :uuid, :limit => 255
      t.string :type, :limit => 255

      t.timestamps
    end
  end

  def down
    drop_table :compute_resources
  end
end
