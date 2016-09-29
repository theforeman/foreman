class AddUserdataFlagToImages < ActiveRecord::Migration
  def change
    add_column :images, :user_data, :boolean, :default => false
  end
end
