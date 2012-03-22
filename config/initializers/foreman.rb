require 'foreman'
require 'puppet'
require 'puppet/rails'
# import settings file
SETTINGS= YAML.load_file("#{Rails.root}/config/settings.yaml")

SETTINGS[:version] = "0.5"

SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
Puppet[:config] = SETTINGS[:puppetconfdir] || "/etc/puppet/puppet.conf"
Puppet.parse_config
$puppet = Puppet.settings.instance_variable_get(:@values) if Rails.env == "test"
SETTINGS[:login] ||= SETTINGS[:ldap]

begin
  if SETTINGS[:unattended]
    Bundler.setup(:virt)
    require 'virt'
    SETTINGS[:libvirt] = true
  else
    SETTINGS[:libvirt] = false
  end
rescue LoadError
  Rails.logger.debug "Libvirt binding are missing - hypervisor management is disabled"
  SETTINGS[:libvirt] = false
end

# We load the default settings if they are not already present
Foreman::DefaultSettings::Loader.load

# We load the default settings for the roles if they are not already present
Foreman::DefaultData::Loader.load(false)

WillPaginate.per_page = Setting.entries_per_page rescue 20
