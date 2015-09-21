# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE
require File.expand_path('../lib/regexp_extensions', FOREMAN_GEMFILE)

source 'https://rubygems.org'

gem 'rails', '4.1.5'
gem 'json', '~> 1.5'
gem 'rest-client', '~> 1.6.0', :require => 'rest_client'
gem 'audited-activerecord' #, '3.0.0'
gem 'will_paginate', '~> 3.0'
gem 'ancestry', '~> 2.0'
gem 'scoped_search', '>= 3.2.2'
gem 'ldap_fluff', '>= 0.3.5', '< 1.0'
gem 'net-ldap', '>= 0.8.0'
gem 'apipie-rails', '~> 0.3.4'
gem 'rabl', '~> 0.11'
gem 'oauth', '~> 0.4'
gem 'deep_cloneable', '~> 2.0'
gem 'foreigner', '~> 1.4'
gem 'validates_lengths_from_database',  '~> 0.2'
gem 'friendly_id', '~> 5.0'
gem 'secure_headers', '~> 1.3'
gem 'safemode', '~> 1.2'
gem 'fast_gettext', '~> 0.8'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'i18n', '~> 0.6.4'
gem 'rails-i18n'#, '~> 3.0.0'
gem 'turbolinks', '~> 2.5'
gem 'logging', '>= 1.8.0', '< 3.0.0'
gem 'activerecord-session_store'
gem 'rails-observers'

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
