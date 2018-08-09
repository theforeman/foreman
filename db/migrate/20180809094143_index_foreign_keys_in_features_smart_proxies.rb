class IndexForeignKeysInFeaturesSmartProxies < ActiveRecord::Migration[5.1]
  def change
    add_index :features_smart_proxies, :feature_id
    add_index :features_smart_proxies, :smart_proxy_id
  end
end
