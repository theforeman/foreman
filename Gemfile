# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE
require File.expand_path('../config/settings', FOREMAN_GEMFILE)
require File.expand_path('../lib/regexp_extensions', FOREMAN_GEMFILE)

source 'https://rubygems.org'

gem 'rails', '3.2.21'
gem 'rake', '< 11'
gem 'rack-cache', '< 1.3.0'
gem 'json', '~> 1.5'
gem 'rest-client', '~> 1.6.0', :require => 'rest_client'
gem 'audited-activerecord', '3.0.0'
gem 'will_paginate', '~> 3.0'
gem 'ancestry', '~> 2.0'
gem 'scoped_search', '~> 2.7'
gem 'ldap_fluff', '>= 0.3.4', '< 1.0'
gem 'apipie-rails', '~> 0.2.5'
gem 'rabl', '~> 0.11'
gem 'oauth', '~> 0.4'
gem 'deep_cloneable', '~> 2.0'
gem 'foreigner', '~> 1.4'
gem 'validates_lengths_from_database',  '~> 0.2'
gem 'friendly_id', '~> 4.0'
gem 'secure_headers', '~> 1.3'
gem 'safemode', '~> 1.2'
gem 'fast_gettext', '~> 0.8'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'i18n', '~> 0.6.4'
gem 'turbolinks', '~> 2.5'

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
