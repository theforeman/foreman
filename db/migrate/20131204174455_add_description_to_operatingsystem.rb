class AddDescriptionToOperatingsystem < ActiveRecord::Migration
  def change
    add_column :operatingsystems, :description, :string, :limit => 255
  end
end
