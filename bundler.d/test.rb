group :test do
  gem 'mocha', :require => false
  gem 'minitest', '~> 3.5', :platforms => [:ruby_19, :ruby_20]
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
  gem 'simplecov', :platforms => [:ruby_19, :ruby_20]
end
