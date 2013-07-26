class AddQuotaidToComputeResources < ActiveRecord::Migration
  def self.up
    add_column :compute_resources, :default_quota_id, :string unless column_exists? :compute_resources, :default_quota_id
  end

  def self.down
    remove_column :compute_resources, :default_quota_id if column_exists? :compute_resources, :default_quota_id
  end
end
