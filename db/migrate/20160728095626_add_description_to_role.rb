class AddDescriptionToRole < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :description, :text
  end
end
