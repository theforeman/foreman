require_relative 'boot_settings'
require_relative '../app/services/foreman/version'

root = File.expand_path(File.dirname(__FILE__) + "/..")
settings_file = Rails.env.test? ? 'config/settings.yaml.test' : 'config/settings.yaml'

SETTINGS.merge! YAML.load(ERB.new(File.read("#{root}/#{settings_file}")).result) if File.exist?(settings_file)
SETTINGS[:version] = Foreman::Version.new

# default to true if missing
[:unattended, :login, :locations_enabled, :organizations_enabled].each do |setting|
  SETTINGS[setting] = SETTINGS[setting].nil? || SETTINGS[setting]
end

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
