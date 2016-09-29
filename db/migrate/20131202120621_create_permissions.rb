class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :name, :null => false, :limit => 255
      t.string :resource_type, :limit => 255

      t.timestamps
    end

    add_index :permissions, [:name, :resource_type]
  end
end
