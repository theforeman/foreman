class ActuallyRenameSmartProxyAuthRelatedSettings < ActiveRecord::Migration[4.2]
  def up
    %w(restrict_registered require_ssl).each do |setting|
      if (old = Setting.find_by_name("#{setting}_puppetmasters"))
        Setting["#{setting}_smart_proxies"] = old.value
        old.delete
      end
    end
  end

  def down
    execute "UPDATE settings SET name='restrict_registered_puppetmasters' WHERE name='restrict_registered_smart_proxies'"
    execute "UPDATE settings SET name='require_ssl_puppetmasters' WHERE name='require_ssl_smart_proxies'"
  end
end
