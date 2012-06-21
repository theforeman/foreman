class CreateOrganizationSmartProxies < ActiveRecord::Migration
  def self.up
    create_table :organization_smart_proxies do |t|
      t.integer :organization_id
      t.integer :smart_proxy_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_smart_proxies
  end
end
