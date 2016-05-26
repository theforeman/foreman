class AddFilteredApiToOvirt < ActiveRecord::Migration
  def change
    add_column :compute_resources, :filtered_api, :boolean, :default => false, :null => false
  end
end
