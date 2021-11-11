class CreateMediaOperatingsystemsAndMigrateData < ActiveRecord::Migration[4.2]
  def up
    create_table :media_operatingsystems, :id => false do |t|
      t.references :medium, :null => false
      t.references :operatingsystem, :null => false
    end

    remove_column :media, :operatingsystem_id
  end

  def down
    add_column :media, :operatingsystem_id, :integer
    drop_table :media_operatingsystems
  end
end
