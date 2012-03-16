source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem "jquery-rails"
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem "acts_as_audited", "2.0.0"
gem "has_many_polymorphs", :git => "https://github.com/jystewart/has_many_polymorphs.git", :ref => '03429a61e511f394e9f96af0c8998268ca99d42b'
gem "will_paginate", "~> 3.0.2"
gem "ancestry", "~> 1.2.4"
gem "puppet"

group :sqlite do
  gem 'sqlite3'
end

group :mysql do
  gem 'mysql'
end

group :postgresql do
  gem 'pg'
end

gem 'scoped_search', '>= 2.3.6'
#group :provisioning do
  gem "safemode", "~> 1.0.1"
  gem "virt", ">= 0.2.1"
#end

group :authentication do
  gem 'net-ldap'
end

group :test do
  gem 'mocha'
  gem 'shoulda'
  gem 'rr'
  gem 'rake'
end

group :development do
  # To use debugger
  gem "ruby-debug", :platforms => :ruby_18
  gem "ruby-debug19", :platforms => :ruby_19
end
