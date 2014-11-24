class RenameSmartProxyAuthRelatedSettings < ActiveRecord::Migration
  def self.up
    execute "UPDATE settings SET name='restrict_registered_smart_proxies' WHERE name='restrict_registered_smart_proxies'"
    execute "UPDATE settings SET name='require_ssl_smart_proxies' WHERE name='require_ssl_smart_proxies'"
  end

  def self.down
    execute "UPDATE settings SET name='restrict_registered_smart_proxies' WHERE name='restrict_registered_smart_proxies'"
    execute "UPDATE settings SET name='require_ssl_smart_proxies' WHERE name='require_ssl_smart_proxies'"
  end
end
