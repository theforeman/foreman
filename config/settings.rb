root = File.expand_path(File.dirname(__FILE__) + "/..")
require 'yaml'
require "#{root}/app/services/foreman/version"

SETTINGS = YAML.load_file("#{root}/config/settings.yaml")
SETTINGS[:version] = Foreman::Version.new
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:ldap]
SETTINGS[:puppetconfdir] ||= '/etc/puppet'
SETTINGS[:puppetvardir]  ||= '/var/lib/puppet'

products = YAML.load_file("#{root}/config/products.yml")
SETTINGS[:name] = (products[:foreman] || "Foreman").chomp
SETTINGS[:smart_proxy_name] = (products[:smart_proxy] || "Smart Proxy").chomp

# Load plugin config, if any
Dir["#{root}/config/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load_file f
end
