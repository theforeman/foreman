require 'yaml'
root     = File.expand_path(File.dirname(__FILE__) + "/..")
SETTINGS = YAML.load_file("#{root}/config/settings.yaml")
SETTINGS[:version]    = File.read(root + "/VERSION").chomp rescue ("N/A")
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:ldap]
SETTINGS[:puppetconfdir] ||= '/etc/puppet'
SETTINGS[:puppetvardir]  ||= '/var/lib/puppet'
