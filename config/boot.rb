require 'rubygems'

unless File.exist?(File.expand_path('../Gemfile.in', __dir__))
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
  require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
end
