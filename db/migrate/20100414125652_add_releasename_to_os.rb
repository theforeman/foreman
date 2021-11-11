class AddReleasenameToOs < ActiveRecord::Migration[4.2]
  def up
    add_column :operatingsystems, :release_name, :string, :limit => 64
  end

  def down
    remove_column :operatingsystems, :release_name
  end
end
