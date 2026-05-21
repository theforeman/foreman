class AddSmartProxyIdIndexToSmartProxyFeatures < ActiveRecord::Migration[6.1]
  def change
    add_index :smart_proxy_features, :smart_proxy_id
  end
end
