class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :name, :null => false
      t.string :resource_type

      t.timestamps
    end

    add_index :permissions, [:name, :resource_type]
  end
end
