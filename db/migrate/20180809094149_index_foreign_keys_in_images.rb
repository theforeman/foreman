class IndexForeignKeysInImages < ActiveRecord::Migration[5.1]
  def change
    add_index :images, :architecture_id
    add_index :images, :compute_resource_id
    add_index :images, :operatingsystem_id
  end
end
