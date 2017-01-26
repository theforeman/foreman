class AddCachingEnabledToComputeResource < ActiveRecord::Migration
  def change
    add_column :compute_resources, :caching_enabled, :boolean, default: true
  end
end
