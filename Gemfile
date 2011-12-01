source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem "jquery-rails"
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem "acts_as_audited", "2.0.0"
gem "has_many_polymorphs", :git => "https://github.com/jystewart/has_many_polymorphs.git"
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 1.2.4"

# Should force the user to choose depending on their database.
#gem "sqlite3"
#gem "mysql2"
#gem "pg"

gem 'scoped_search', '>= 2.3.4'
gem "puppet", "~> 2"

#group :provisioning do
  gem "safemode", "1.0", :git => "https://github.com/svenfuchs/safemode.git"
  gem "ruby2ruby"
  gem "ruby_parser"
  gem "ruby-libvirt"
  gem "virt", ">= 0.2.0"
#end

group :authentication do
  gem 'net-ldap'
end

group :test, :development do
  # To use debugger
  gem 'ruby-debug'
  gem 'mocha'
  gem 'shoulda'
  gem 'rr'
end
