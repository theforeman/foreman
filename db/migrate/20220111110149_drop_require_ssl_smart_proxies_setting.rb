class DropRequireSslSmartProxiesSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: 'require_ssl_smart_proxies').delete_all
  end
end
