require 'config/settings'
source 'http://rubygems.org'

gem 'rails', '3.0.17'
gem "jquery-rails"
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem "audited-activerecord", "3.0.0.rc1"
gem "has_many_polymorphs", :git => "https://github.com/jystewart/has_many_polymorphs.git", :ref => '03429a61e511f394e9f96af0c8998268ca99d42b'
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 1.2.4"
gem 'scoped_search', '>= 2.4'
gem 'net-ldap'
gem "safemode", "~> 1.0.1"
gem 'uuidtools'
gem "apipie-rails", ">= 0.0.12"
gem 'rabl', '>= 0.7.5'
# Previous versions collide with Environment model
gem "ruby_parser", ">= 2.3.1"
gem 'oauth'

Dir["#{File.dirname(__FILE__)}/bundler.d/*.rb"].each do |bundle|
 # puts "adding custom gem file #{bundle}"
  self.instance_eval(Bundler.read_file(bundle))
end
