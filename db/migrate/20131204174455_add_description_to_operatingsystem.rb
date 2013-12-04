class AddDescriptionToOperatingsystem < ActiveRecord::Migration
  def change
    add_column :operatingsystems, :description, :string
  end
end
