class AddCachingEnabledToComputeResource < ActiveRecord::Migration[4.2]
  def change
    add_column :compute_resources, :caching_enabled, :boolean, default: true
  end
end
