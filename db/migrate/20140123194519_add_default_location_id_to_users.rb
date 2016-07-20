class AddDefaultLocationIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :default_location_id, :integer
  end
end
