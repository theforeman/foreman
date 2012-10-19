require File.expand_path('../config/settings', __FILE__)
source 'http://rubygems.org'

gem 'rails', '3.0.17'
gem "jquery-rails"
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem "audited-activerecord", "3.0.0.rc1"
gem "has_many_polymorphs", :git => "https://github.com/jystewart/has_many_polymorphs.git", :ref => '03429a61e511f394e9f96af0c8998268ca99d42b'
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 1.3"
gem 'scoped_search', '>= 2.4'
gem 'net-ldap'
gem 'uuidtools'
gem "apipie-rails", ">= 0.0.12"
gem 'rabl', '>= 0.7.5'
gem 'oauth'

if RUBY_VERSION >= '1.9.3'
  gem 'safemode', :git => "git://github.com/witlessbird/safemode.git", :branch => "1.9.3"
else
  gem 'safemode'
  # Previous versions collide with Environment model
  gem 'ruby_parser', '>= 2.3.1'
end


Dir["#{File.dirname(__FILE__)}/bundler.d/*.rb"].each do |bundle|
 # puts "adding custom gem file #{bundle}"
  self.instance_eval(Bundler.read_file(bundle))
end
