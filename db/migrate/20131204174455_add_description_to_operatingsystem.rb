class AddDescriptionToOperatingsystem < ActiveRecord::Migration[4.2]
  def change
    add_column :operatingsystems, :description, :string, :limit => 255
  end
end
