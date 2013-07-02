group :test do
  gem 'mocha', :require => false
  unless RUBY_VERSION =~ /^1\.8/
    gem 'simplecov'
    gem 'spork-minitest'
  end
  gem 'single_test'
  gem 'rr'
  gem 'minitest', '~> 4.7'
  gem 'minitest-spec-rails'
  gem 'minitest-spec-rails-tu-shim', :platforms => :ruby_18
  gem 'ci_reporter', '>= 1.6.3', :require => false
  gem 'capybara', '~> 2.0.0'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'spork'
end
