class AddDescriptionToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :description, :text
  end
end
