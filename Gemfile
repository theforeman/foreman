require File.expand_path('../config/settings', __FILE__)
source 'http://rubygems.org'

gem 'rails', '3.0.19'
gem "jquery-rails"
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem "audited-activerecord", "3.0.0.rc1"
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 1.3"
gem 'scoped_search', '>= 2.4'
gem 'net-ldap'
gem "safemode", "~> 1.1.0"
gem 'ruby_parser', '~> 3.0.0'
gem 'uuidtools'
gem "apipie-rails", ">= 0.0.12"
gem 'rabl', '>= 0.7.5'
gem 'oauth'

Dir["#{File.dirname(__FILE__)}/bundler.d/*.rb"].each do |bundle|
 # puts "adding custom gem file #{bundle}"
  self.instance_eval(Bundler.read_file(bundle))
end
