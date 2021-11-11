class ChangeFamilyInOs < ActiveRecord::Migration[4.2]
  def up
    add_column :operatingsystems, :type, :string, :limit => 16
    add_index :operatingsystems, :type

    remove_column :operatingsystems, :family_id
  end

  def down
    add_column :operatingsystems, :family_id, :integer

    remove_index :operatingsystems, :type
    remove_column :operatingsystems, :type
  end
end
