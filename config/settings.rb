require_relative 'boot_settings'
require_relative '../app/services/foreman/version'

root = File.expand_path(File.dirname(__FILE__) + "/..")
settings_file = Rails.env.test? ? 'config/settings.yaml.test' : 'config/settings.yaml'

SETTINGS.merge! YAML.load(ERB.new(File.read("#{root}/#{settings_file}")).result) if File.exist?(settings_file)
SETTINGS[:version] = Foreman::Version.new
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:login].nil? || SETTINGS[:ldap]
SETTINGS[:rails] = '%.1f' % SETTINGS[:rails] if SETTINGS[:rails].is_a?(Float) # unquoted YAML value
SETTINGS[:hsts_enabled] = true unless SETTINGS.has_key?(:hsts_enabled)

unless SETTINGS[:domain] && SETTINGS[:fqdn]
  require 'facter'
  SETTINGS[:domain] ||= Facter.value(:domain) || Facter.value(:hostname)
  SETTINGS[:fqdn] ||= Facter.value(:fqdn)
end

# Load plugin config, if any
Dir["#{root}/config/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load(ERB.new(File.read(f)).result)
end
