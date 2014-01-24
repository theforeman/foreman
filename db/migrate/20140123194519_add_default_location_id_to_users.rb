class AddDefaultLocationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_location_id, :integer
  end
end
