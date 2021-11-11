class AddIndexesOnImages < ActiveRecord::Migration[5.0]
  def up
    add_index :images, [:name, :compute_resource_id, :operatingsystem_id], name: 'image_name_index', unique: true
    add_index :images, [:uuid, :compute_resource_id], name: 'image_uuid_index', unique: true
  end

  def down
    remove_index :images, name: 'image_name_index'
    remove_index :images, name: 'image_uuid_index'
  end
end
