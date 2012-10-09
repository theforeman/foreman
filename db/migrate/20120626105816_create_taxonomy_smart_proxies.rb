class CreateTaxonomySmartProxies < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_smart_proxies, :id => false do |t|
      t.integer :taxonomy_id
      t.integer :smart_proxy_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_smart_proxies
  end
end
