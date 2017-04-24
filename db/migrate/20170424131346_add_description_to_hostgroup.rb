class AddDescriptionToHostgroup < ActiveRecord::Migration
  def change
    add_column :hostgroups, :description, :text
  end
end
