require_relative 'boot_settings'
require_relative '../app/services/foreman/version'
require_relative '../app/services/foreman/env_settings_loader'

root = File.expand_path(File.dirname(__FILE__) + "/..")
settings_file = Rails.env.test? ? 'config/settings.yaml.test' : 'config/settings.yaml'

SETTINGS.merge! YAML.load(ERB.new(File.read("#{root}/#{settings_file}")).result) if File.exist?(settings_file)
SETTINGS[:version] = Foreman::Version.new

# Load settings from env variables
SETTINGS.deep_merge!(Foreman::EnvSettingsLoader.new.to_h)

# Force setting to true until all code using it is removed
[:locations_enabled, :organizations_enabled].each do |setting|
  SETTINGS[setting] = true
end

# default to true if missing
[:unattended, :hsts_enabled].each do |setting|
  SETTINGS[setting] = SETTINGS.fetch(setting, true)
end

SETTINGS[:rails] = '%.1f' % SETTINGS[:rails] if SETTINGS[:rails].is_a?(Float) # unquoted YAML value

unless SETTINGS[:domain] && SETTINGS[:fqdn]
  require 'facter'
  SETTINGS[:domain] ||= Facter.value(:domain) || Facter.value(:hostname)
  SETTINGS[:fqdn] ||= Facter.value(:fqdn)
end

# Load plugin config, if any
Dir["#{root}/config/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load(ERB.new(File.read(f)).result)
end
