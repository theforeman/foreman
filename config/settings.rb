require_relative 'boot_settings'
require_relative '../app/services/foreman/version'
require 'facter'

root = File.expand_path(File.dirname(__FILE__) + "/..")
settings_file = Rails.env.test? ? 'config/settings.yaml.test' : 'config/settings.yaml'

SETTINGS.merge! YAML.load(ERB.new(File.read("#{root}/#{settings_file}")).result)
SETTINGS[:version] = Foreman::Version.new
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:ldap]
SETTINGS[:puppetconfdir] ||= '/etc/puppet'
SETTINGS[:puppetvardir]  ||= '/var/lib/puppet'
SETTINGS[:puppetssldir]  ||= "#{SETTINGS[:puppetvardir]}/ssl"
SETTINGS[:rails] = '%.1f' % SETTINGS[:rails] if SETTINGS[:rails].is_a?(Float) # unquoted YAML value
SETTINGS[:domain] ||= Facter.value(:domain) || Facter.value(:hostname)

# Load plugin config, if any
Dir["#{root}/config/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load(ERB.new(File.read(f)).result)
end
