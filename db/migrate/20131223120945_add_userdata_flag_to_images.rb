class AddUserdataFlagToImages < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :user_data, :boolean, :default => false
  end
end
