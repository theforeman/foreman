# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE
require File.expand_path('../config/settings', FOREMAN_GEMFILE)
require File.expand_path('../lib/regexp_extensions', FOREMAN_GEMFILE)

source 'https://rubygems.org'

gem 'rails', '3.2.21'
gem 'json', '~> 1.5'
gem 'rest-client', '~> 1.6', :require => 'rest_client'
gem 'audited-activerecord', '3.0.0'
gem 'will_paginate', '~> 3.0'
gem 'ancestry', '~> 2.0'
gem 'scoped_search', '~> 2.7'
gem 'ldap_fluff', '~> 0.3'
gem 'apipie-rails', '~> 0.2.5'
gem 'rabl', '~> 0.11'
gem 'oauth', '~> 0.4'
gem 'deep_cloneable', '~> 2.0'
gem 'foreigner', '~> 1.4'
gem 'validates_lengths_from_database',  '~> 0.2'
gem 'friendly_id', '~> 4.0'
gem 'secure_headers', '~> 1.3'
gem 'safemode', '~> 1.2'
gem 'ruby_parser', '3.1.1'


Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
