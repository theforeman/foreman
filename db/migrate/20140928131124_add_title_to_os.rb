class AddTitleToOs < ActiveRecord::Migration[4.2]
  def up
    add_column :operatingsystems, :title, :string, :limit => 255
  end

  def down
    remove_column :operatingsystems, :title
  end
end
