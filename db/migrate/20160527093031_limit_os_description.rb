class LimitOsDescription < ActiveRecord::Migration[4.2]
  def up
    change_column :operatingsystems, :description, :string, :limit => 255
  end

  def down
    change_column :operatingsystems, :description, :text
  end
end
