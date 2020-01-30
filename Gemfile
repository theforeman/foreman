# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE

require_relative 'config/boot_settings'

source 'https://rubygems.org'

case SETTINGS[:rails]
when '6.0'
  gem 'rails', '~> 6.0.2.2'
else
  raise "Unsupported Ruby on Rails version configured in settings.yaml: #{SETTINGS[:rails]}"
end

gem 'rest-client', '>= 2.0.0', '< 3', :require => 'rest_client'
gem 'audited', '>= 4.9.0', '< 5'
gem 'will_paginate', '>= 3.1.7', '< 4'
gem 'ancestry', '>= 3.0.7', '< 4'
gem 'scoped_search', '>= 4.1.8', '< 5'
gem 'ldap_fluff', '>= 0.4.7', '< 1.0'
gem 'apipie-rails', '>= 0.5.17', '< 0.6.0'
gem 'apipie-dsl', '>= 2.2.2'
gem 'rabl', '~> 0.14.2'
gem 'oauth', '>= 0.5.4', '< 1'
gem 'deep_cloneable', '>= 3', '< 4'
gem 'validates_lengths_from_database', '~> 0.5'
gem 'friendly_id', '>= 5.3.0', '< 6'
gem 'secure_headers', '~> 6.3'
gem 'safemode', '>= 1.3.5', '< 2'
gem 'fast_gettext', '~> 1.4'
gem 'gettext_i18n_rails', '~> 1.8'
gem 'rails-i18n', '~> 6.0'
gem 'i18n', '~> 1.1'
gem 'logging', '>= 1.8.0', '< 3.0.0'
gem 'fog-core', '2.1.0'
gem 'net-scp'
gem 'net-ssh', '4.2.0'
gem 'net-ldap', '>= 0.16.0'
gem 'net-ping', :require => false
gem 'activerecord-session_store', '>= 1.1.0', '< 2'
gem 'sprockets', '~> 3'
gem 'sprockets-rails', '~> 3.0'
gem 'record_tag_helper', '~> 1.0'
gem 'responders', '~> 3.0'
gem 'roadie-rails', '~> 2.0'
gem 'deacon', '~> 1.0'
gem 'webpack-rails', '~> 0.9.8'
gem 'mail', '~> 2.7'
gem 'sshkey', '~> 1.9'
gem 'dynflow', '>= 1.4.0', '< 2.0.0'
gem 'daemons'
gem 'bcrypt', '~> 3.1'
gem 'get_process_mem'
gem 'rack-cors', '~> 1.0.2', require: 'rack/cors'
gem 'jwt', '~> 2.2.1'
gem 'graphql', '~> 1.8.0'
gem 'graphql-batch'

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  instance_eval(Bundler.read_file(bundle))
end
