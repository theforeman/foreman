require 'rubygems'
require 'yaml'
require File.expand_path('../../config/settings', __FILE__)

unless File.exist?(File.expand_path('../../Gemfile.in', __FILE__))
  ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
  require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
end
