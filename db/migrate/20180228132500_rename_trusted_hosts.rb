class RenameTrustedHosts < ActiveRecord::Migration[5.1]
  def up
    trusted_puppetmaster_hosts = Setting.find_by_name('trusted_puppetmaster_hosts')
    trusted_hosts = Setting.find_by_name('trusted_hosts')
    return unless trusted_hosts.present? && trusted_puppetmaster_hosts.present?
    trusted_hosts.update_attribute(
      :value,
      trusted_puppetmaster_hosts.value
    )
    trusted_puppetmaster_hosts.destroy
  end

  def down
    trusted_puppetmaster_hosts = Setting.find_by_name('trusted_puppetmaster_hosts')
    trusted_hosts = Setting.find_by_name('trusted_hosts')
    return unless trusted_hosts.present? && trusted_puppetmaster_hosts.present?
    trusted_puppetmaster_hosts.update(
      :name => 'trusted_hosts',
      :value => trusted_hosts.value
    )
    trusted_hosts.destroy
  end
end
