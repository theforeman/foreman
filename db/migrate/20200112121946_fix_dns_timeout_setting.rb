class FixDnsTimeoutSetting < ActiveRecord::Migration[5.2]
  def up
    Setting.find_by_name('dns_timeout')&.update_column(:value, nil) if Setting[:dns_timeout] == [nil]
  end
end
