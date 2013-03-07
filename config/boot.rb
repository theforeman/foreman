require 'rubygems'
require 'yaml'
require File.expand_path('../../config/settings', __FILE__)

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
    print "Libvirt bindings are missing - hypervisor management is disabled"
    SETTINGS[:libvirt] = false
  end
end
