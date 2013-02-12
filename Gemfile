require File.expand_path('../config/settings', __FILE__)
require File.expand_path('../lib/regexp_extensions', __FILE__)
source 'http://rubygems.org'

gem 'rails', '3.2.12'
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem "audited-activerecord", "3.0.0.rc1"
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 1.3"
gem 'scoped_search', '>= 2.4'
gem 'net-ldap'
gem 'uuidtools'
gem "apipie-rails", '0.0.16'
gem 'rabl', '>= 0.7.5'
gem 'oauth'

if RUBY_VERSION =~ /^1\.8/
  # Older version of safemode for Ruby 1.8, as the latest causes regexp overflows (#2100)
  gem 'safemode', '~> 1.0.1'
  gem 'ruby_parser', '>= 2.3.1', '< 3.0'
else
  # Newer version of safemode contains fixes for Ruby 1.9
  gem 'safemode', '~> 1.2'
  gem 'ruby_parser', '~> 3.0.0'
end

Dir["#{File.dirname(__FILE__)}/bundler.d/*.rb"].each do |bundle|
 # puts "adding custom gem file #{bundle}"
  self.instance_eval(Bundler.read_file(bundle))
end
