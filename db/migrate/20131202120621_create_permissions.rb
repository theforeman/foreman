class CreatePermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :permissions do |t|
      t.string :name, :null => false, :limit => 255
      t.string :resource_type, :limit => 255

      t.timestamps null: true
    end

    add_index :permissions, [:name, :resource_type]
  end
end
