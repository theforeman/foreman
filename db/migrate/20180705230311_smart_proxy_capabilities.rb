class SmartProxyCapabilities < ActiveRecord::Migration[5.1]
  def up
    rename_table :features_smart_proxies, :smart_proxy_features
    change_table :smart_proxy_features, :bulk => true do |t|
      t.primary_key :id
      t.text :capabilities
      t.text :settings
    end
  end

  def down
    change_table :smart_proxy_features do |t|
      t.remove :settings, :capabilities, :id
    end
    rename_table :smart_proxy_features, :features_smart_proxies
  end
end
