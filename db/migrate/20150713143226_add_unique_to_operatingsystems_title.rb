class AddUniqueToOperatingsystemsTitle < ActiveRecord::Migration[4.2]
  def up
    add_index :operatingsystems, :title, :unique => true
    change_column_null :operatingsystems, :name, false
    add_index :operatingsystems, [:name, :major, :minor], :unique => true
  end

  def down
    remove_index :operatingsystems, :title
    change_column_null :operatingsystems, :name, true
    remove_index :operatingsystems, [:name, :major, :minor]
  end
end
