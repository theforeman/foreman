group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'mocha', :require => false
  gem 'minitest', '~> 3.5', :platforms => :ruby_19
  gem 'single_test'
  gem 'shoulda', "3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'single_test'
  gem 'ci_reporter', '>= 1.6.3', :require => false
  gem 'minitest', '~> 3.5', :platforms => :ruby_19
end
