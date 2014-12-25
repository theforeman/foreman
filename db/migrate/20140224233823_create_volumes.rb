class CreateVolumes < ActiveRecord::Migration
  def up
    create_table :volumes do |t|
      t.integer :compute_resource_id
      t.string :uuid
      t.string :name
      t.string :status
      t.string :size
      t.string :availability_zone

      t.timestamps
    end
  end

  def down
    drop_table :volumes
  end
end
