class RenameTrustedHosts < ActiveRecord::Migration[5.1]
  def up
    trusted_puppetmaster_hosts = Setting.where(name: 'trusted_puppetmaster_hosts')
    return unless trusted_puppetmaster_hosts.exists?
    trusted_hosts = Setting.where(name: 'trusted_hosts')
    trusted_hosts.update_all(
      value: trusted_puppetmaster_hosts.pick(:value)
    )
    trusted_puppetmaster_hosts.delete_all
  end

  def down
    trusted_hosts = Setting.where(name: 'trusted_hosts')
    return unless trusted_hosts.exists?
    trusted_puppetmaster_hosts = Setting.where(name: 'trusted_puppetmaster_hosts')
    trusted_puppetmaster_hosts.update_all(
      value: trusted_hosts.pick(:value)
    )
    trusted_hosts.delete_all
  end
end
