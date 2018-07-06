class SmartProxyCapabilities < ActiveRecord::Migration[5.1]
  def up
    rename_table :features_smart_proxies, :smart_proxy_features
    change_table :smart_proxy_features do |t|
      t.primary_key :id
      t.text :capabilities, array: true
      if t.respond_to?(:jsonb)
        t.jsonb :settings
      elsif t.respond_to?(:json)
        t.json :settings
      else
        t.text :settings
      end
    end
  end

  def down
    change_table :smart_proxy_features do |t|
      t.remove :settings, :capabilities, :id
    end
    rename_table :smart_proxy_features, :features_smart_proxies
  end
end
