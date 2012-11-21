require 'rubygems'
require 'yaml'

root     = File.expand_path(File.dirname(__FILE__) + "/..")
SETTINGS = YAML.load_file("#{root}/config/settings.yaml")
SETTINGS[:version]    = File.read(root + "/VERSION").chomp rescue ("N/A")
SETTINGS[:unattended] = SETTINGS[:unattended].nil? || SETTINGS[:unattended]
SETTINGS[:login]    ||= SETTINGS[:ldap]

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

if File.exists?(ENV['BUNDLE_GEMFILE'])
  require 'bundler'
  Bundler.setup

  begin
    if SETTINGS[:unattended]
      Bundler.setup(:unattended)
      Bundler.setup(:libvirt)
      require 'libvirt'
      SETTINGS[:libvirt] = true
    else
      SETTINGS[:libvirt] = false
    end
  rescue LoadError
    warn "Libvirt binding are missing - hypervisor management is disabled"
    SETTINGS[:libvirt] = false
  end

  require 'rack/jsonp' if SETTINGS[:support_jsonp]

end
