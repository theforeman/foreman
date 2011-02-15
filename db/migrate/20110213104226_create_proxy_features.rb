class CreateProxyFeatures < ActiveRecord::Migration

  def self.up
    # Create the tables
    create_table :features do |t|
      t.string :name, :limit => 16
      t.timestamps
    end
    Feature.create(:name => "TFTP")
    Feature.create(:name => "DNS")
    Feature.create(:name => "DHCP")
    Feature.create(:name => "Puppet CA")
    Feature.create(:name => "Puppet")

    create_table :features_smart_proxies, :id => false do |t|
      t.references :smart_proxy
      t.references :feature
    end

  end

  def self.down
    drop_table :features
    drop_table :features_smart_proxies
  end
end
