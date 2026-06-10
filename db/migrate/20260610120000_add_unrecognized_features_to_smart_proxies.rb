class AddUnrecognizedFeaturesToSmartProxies < ActiveRecord::Migration[7.0]
  def change
    add_column :smart_proxies, :unrecognized_features, :text
  end
end
