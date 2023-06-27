require_relative '../app/services/foreman/version'
require_relative '../app/services/foreman/env_settings_loader'

settings_file = File.join(__dir__, Rails.env.test? ? 'settings.yaml.test' : 'settings.yaml')

SETTINGS = {}
SETTINGS.merge! YAML.load(ERB.new(File.read(settings_file)).result) if File.exist?(settings_file)
SETTINGS[:version] = Foreman::Version.new

# Load settings from env variables
SETTINGS.deep_merge!(Foreman::EnvSettingsLoader.new.to_h)

# foreman-documentation builds different flavors for Debian and Enterprise
# Linux. It also builds for Katello, but we can't detect that here so the key
# is docs_os_flavor instead of docs_flavor.
SETTINGS[:docs_os_flavor] ||= File.exist?('/etc/debian_version') ? 'foreman-deb' : 'foreman-el'

# Force setting to true until all code using it is removed
[:locations_enabled, :organizations_enabled, :unattended].each do |setting|
  SETTINGS[setting] = true
end

# default to true if missing
[:hsts_enabled].each do |setting|
  SETTINGS[setting] = SETTINGS.fetch(setting, true)
end

unless SETTINGS[:domain] && SETTINGS[:fqdn]
  require 'facter'
  SETTINGS[:domain] ||= Facter.value(:domain) || Facter.value(:hostname)
  SETTINGS[:fqdn] ||= Facter.value(:fqdn)
end

SETTINGS[:hosts] ||= []

SETTINGS[:trusted_redirect_domains] ||= ['theforeman.org', 'redhat.com', 'orcharhino.com'].freeze

# Load plugin config, if any
Dir["#{__dir__}/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load(ERB.new(File.read(f)).result)
end
