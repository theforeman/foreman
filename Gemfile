# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE

source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'rest-client', '>= 1.8.0', '< 3', :require => 'rest_client'
gem 'audited-activerecord', '>= 4.2.2', '< 5'
gem 'will_paginate', '~> 3.0'
gem 'ancestry', '~> 2.0'
gem 'scoped_search', '>= 3.2.2', '< 4'
gem 'ldap_fluff', '>= 0.3.5', '< 1.0'
gem 'apipie-rails', '~> 0.3.4'
gem 'rabl', '>= 0.11', "< 0.13"
gem 'oauth', '~> 0.4'
gem 'deep_cloneable', '~> 2.0'
gem 'validates_lengths_from_database', '~> 0.5'
gem 'friendly_id', '~> 5.0'
gem 'secure_headers', '~> 1.3'
gem 'safemode', '~> 1.2', '>= 1.2.4'
gem 'fast_gettext', '>= 0.8', '< 1.2.0'
gem 'gettext_i18n_rails', '~> 1.0'
gem 'rails-i18n', '~> 4.0.0'
gem 'turbolinks', '~> 2.5'
gem 'logging', '>= 1.8.0', '< 3.0.0'
gem 'fog-core', '1.42.0'
gem 'net-scp'
gem 'net-ssh'
gem 'net-ldap', '>= 0.8.0'
gem 'activerecord-session_store', '>= 0.1.1', '< 2'
gem 'sprockets', '~> 3'
gem 'sprockets-rails', '>= 2.3.3', '< 3'
gem 'responders', '~> 2.0'
gem 'roadie-rails', '~> 1.1'
gem 'x-editable-rails', '~> 1.5.5'
gem 'deacon', '~> 1.0'
gem 'webpack-rails', '~> 0.9.8'

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
