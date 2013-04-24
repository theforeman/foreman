group :test do
  gem 'mocha', :require => false
  unless RUBY_VERSION =~ /^1\.8/
    gem 'minitest', '~> 3.5'
    gem 'simplecov'
  end
  gem 'single_test'
  gem 'shoulda', "3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'ci_reporter', '>= 1.6.3', :require => false
  gem 'capybara', '~> 2.0.0'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'spork'
  gem 'spork-testunit'
end
