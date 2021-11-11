class AddFamilyToOs < ActiveRecord::Migration[4.2]
  def up
    add_column :operatingsystems, :family_id, :integer
  end

  def down
    remove_column :operatingsystems, :family_id
  end
end
