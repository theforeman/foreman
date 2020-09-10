class FixDnsTimeoutSetting < ActiveRecord::Migration[5.2]
  def up
    Rails.cache.delete(Setting.cache_key("dns_timeout"))
    Setting.find_by_name('dns_timeout')&.update_column(:value, nil) if Setting[:dns_timeout] == [nil]
    Rails.cache.delete(Setting.cache_key("dns_timeout"))
  end
end
