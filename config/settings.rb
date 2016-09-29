root = File.expand_path(File.dirname(__FILE__) + "/..")
require 'yaml'
require "#{root}/app/services/foreman/version"

settings_file = Rails.env.test? ? 'config/settings.yaml.test' : 'config/settings.yaml'

SETTINGS = YAML.load_file("#{root}/#{settings_file}")
SETTINGS[:version] = Foreman::Version.new
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:ldap]
SETTINGS[:puppetconfdir] ||= '/etc/puppet'
SETTINGS[:puppetvardir]  ||= '/var/lib/puppet'
SETTINGS[:puppetssldir]  ||= "#{SETTINGS[:puppetvardir]}/ssl"

# Load plugin config, if any
Dir["#{root}/config/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load_file f
end
