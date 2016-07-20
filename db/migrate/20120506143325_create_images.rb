class CreateImages < ActiveRecord::Migration[4.2]
  def up
    create_table :images do |t|
      t.integer :operatingsystem_id
      t.integer :compute_resource_id
      t.integer :architecture_id
      t.string :uuid, :limit => 255
      t.string :username, :limit => 255
      t.string :name, :limit => 255

      t.timestamps null: true
    end
  end

  def down
    drop_table :images
  end
end
