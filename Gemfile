# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE
require File.expand_path('../config/settings', FOREMAN_GEMFILE)
require File.expand_path('../lib/regexp_extensions', FOREMAN_GEMFILE)

source 'https://rubygems.org'

gem 'rails', '3.2.18'
gem 'json'
gem 'rest-client', '> 1.6.2', '< 1.7', :require => 'rest_client'
gem "audited-activerecord", "3.0.0"
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 2.0.0"
gem 'scoped_search', '>= 2.7.0', '< 3.0.0'
gem 'net-ldap'
gem 'ldap_fluff', '>= 0.3.0', '< 1.0.0'
gem 'uuidtools'
gem "apipie-rails", "~> 0.2.5"
gem 'rabl', '>= 0.7.5', '<= 0.9.0'
gem 'oauth'
gem 'deep_cloneable', '~> 2.0'
gem 'foreigner', '~> 1.4.2'
gem 'validates_lengths_from_database',  '~> 0.2.0'
gem 'friendly_id', '~> 4.0'
gem 'secure_headers', '~> 1.3.3'

if RUBY_VERSION =~ /^1\.8/
  # Older version of safemode for Ruby 1.8, as the latest causes regexp overflows (#2100)
  gem 'safemode', '~> 1.0.2'
  gem 'ruby_parser', '>= 2.3.1', '< 3.0'

  # Used in fog, rbovirt etc.  1.6.0 breaks Ruby 1.8 compatibility.
  gem 'nokogiri', '~> 1.5.0'

  # 10.2.0 breaks Ruby 1.8 compatibility
  gem 'rake', '< 10.2.0'
else
  # Newer version of safemode contains fixes for Ruby 1.9
  gem 'safemode', '~> 1.2.1'
  gem 'ruby_parser', '~> 3.0.0'
end

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
