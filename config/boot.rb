require 'rubygems'
require 'yaml'

root     = File.expand_path(File.dirname(__FILE__) + "/..")
SETTINGS = YAML.load_file("#{root}/config/settings.yaml")
SETTINGS[:version]    = File.read(root + "/VERSION").chomp rescue ("N/A")
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:ldap]
SETTINGS[:orgs_enabled] ||= SETTINGS[:multi_org] || SETTINGS[:single_org]
if SETTINGS[:multi_org] && SETTINGS[:single_org]
  warn "Cannot have both multi_org and single_org set to true.  Change setting in setting.yaml"
  exit(1)
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

if File.exists?(ENV['BUNDLE_GEMFILE'])
  require 'bundler'
  Bundler.setup

  begin
    if SETTINGS[:unattended]
      Bundler.setup(:unattended)
      Bundler.setup(:virt)
      require 'virt'
      SETTINGS[:libvirt] = true
    else
      SETTINGS[:libvirt] = false
    end
  rescue LoadError
    warn "Libvirt binding are missing - hypervisor management is disabled"
    SETTINGS[:libvirt] = false
  end
end
