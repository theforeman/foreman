class AddSquidFeature < ActiveRecord::Migration

  class Feature < ActiveRecord::Base; end

  def self.up
    Feature.create(:name => "Squid")
    add_column :subnets, :squid_proxy_id, :integer unless column_exists? :subnets, :squid_proxy_id
  end

  def self.down
    Feature.first(:name => "Squid").delete
    remove_column :subnets, :squid_proxy_id, :integer if column_exists? :subnets, :squid_proxy_id
  end
end
