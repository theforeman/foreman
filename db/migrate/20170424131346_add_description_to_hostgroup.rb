class AddDescriptionToHostgroup < ActiveRecord::Migration[4.2]
  def change
    add_column :hostgroups, :description, :text
  end
end
