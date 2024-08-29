# foreman plugins import this file therefore __FILE__ cannot be used
FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE

source 'https://rubygems.org'

gem 'rails', '~> 7.0.3'
gem 'rest-client', '>= 2.0.0', '< 3', :require => 'rest_client'
gem 'audited', '~> 5.0', '!= 5.1.0'
gem 'will_paginate', '~> 3.3'
gem 'ancestry', '~> 4.0'
gem 'scoped_search', '>= 4.1.10', '< 5'
gem 'ldap_fluff', '>= 0.7.0', '< 1.0'
gem 'apipie-rails', '>= 0.8.0', '< 2'
gem 'apipie-dsl', '>= 2.6.2'
# Pin rdoc to prevent updating bundled psych (https://github.com/ruby/rdoc/commit/ebe185c8775b2afe844eb3da6fa78adaa79e29a4)
# Rails 6.0 is incompatible with Psych 4, Rails 6.1 should work
gem 'rdoc', RUBY_VERSION < '3.1' ? '< 6.4' : nil
gem 'rabl', '>= 0.15.0', '< 1'
gem 'oauth', '~> 1.0'
gem 'deep_cloneable', '>= 3', '< 4'
gem 'validates_lengths_from_database', '~> 0.5'
gem 'friendly_id', '>= 5.4.2', '< 6'
gem 'secure_headers', '~> 6.3'
gem 'safemode', '>= 1.4', '< 2'
gem 'fast_gettext', '~> 2.1'
gem 'gettext_i18n_rails', '~> 1.8'
gem 'rails-i18n', '~> 7.0'
gem 'logging', '>= 1.8.0', '< 3.0.0'
gem 'fog-core', '~> 2.1'
gem 'net-scp'
gem 'net-ssh'
gem 'net-ldap', '>= 0.16.0'
gem 'net-ping', :require => false
gem 'activerecord-session_store', '>= 2.0.0', '< 3'
gem 'sprockets', '~> 4.0'
gem 'sprockets-rails', '~> 3.0'
gem 'responders', '~> 3.0'
gem 'roadie-rails', '~> 3.0'
gem 'deacon', '~> 1.0'
gem 'mail', '~> 2.7'
gem 'sshkey', '~> 2.0'
gem 'dynflow', '>= 1.6.5', '< 2.0.0'
gem 'daemons'
gem 'bcrypt', '~> 3.1'
gem 'get_process_mem'
gem 'rack-cors', '~> 1.1', require: 'rack/cors'
gem 'jwt', '>= 2.2.2', '< 3.0'
gem 'graphql', '~> 1.13.0'
gem 'graphql-batch'

# A bundled gem since Ruby 3.0
gem 'rss' if RUBY_VERSION >= '3.0'

# FFI 1.17 needs rubygems 3.3.22+, which is Ruby 3.0+ only
gem "ffi", "<1.17" if RUBY_VERSION < '3.0'

Dir["#{File.dirname(FOREMAN_GEMFILE)}/bundler.d/*.rb"].each do |bundle|
  instance_eval(Bundler.read_file(bundle))
end
