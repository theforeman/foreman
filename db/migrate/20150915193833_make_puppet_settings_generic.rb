class MakePuppetSettingsGeneric < ActiveRecord::Migration
  def up
    Setting::Puppet.all.each do |setting|
      setting.update_column(:category, 'Setting::Configuration')
    end

    rename_setting('puppet_interval', 'configuration_interval')
    rename_setting('trusted_puppetmaster_hosts', 'trusted_hosts')
  end

  def down
    execute "UPDATE settings SET name='puppet_interval' WHERE name='configuration_interval'"
    execute "UPDATE settings SET name='trusted_puppetmaster_hosts' WHERE name='trusted_hosts'"

    Setting::Configuration.all.each do |setting|
      setting.update_column(:category, 'Setting::Puppet')
    end
  end

  private

  def rename_setting(source, destination)
    if (old = Setting.find_by_name(source))
      Setting[destination] = old.value
      old.delete
    end
  end
end
