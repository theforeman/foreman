require 'rubygems'

unless File.exist?(File.expand_path('../Gemfile.in', __dir__))
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
  require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
end

# Bootsnap is a runtime dependency and should be enabled in every environment.
# In RPM installations, Gemfile.in is handled by BundlerExt instead of Bundler.
require('bootsnap/setup') unless Gem::Specification.stubs_for('bootsnap').empty?
