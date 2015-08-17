group :test do
  gem 'mocha', '~> 1.1', :require => false
  gem 'simplecov', '~> 0.9'
  gem 'spork-minitest', '0.0.3'
  gem 'single_test', '~> 0.6'
  gem 'minitest', '~> 5.1.0'
  gem 'minitest-spec-rails', '~> 5.3'
  gem 'ci_reporter_minitest', :require => false
  gem 'capybara', '~> 2.0'
  gem 'database_cleaner', '~> 1.3'
  gem 'launchy', '~> 2.4'
  gem 'spork-rails', '~> 4.0.0'
  gem 'factory_girl_rails', '~> 4.5', :require => false
  gem 'rubocop-checkstyle_formatter', '~> 0.2'
  gem "poltergeist"
  gem 'test-unit' if RUBY_VERSION >= '2.2'
  gem 'test_after_commit', '~> 0.4'
  gem 'shoulda-matchers', '2.8.0'
  gem 'shoulda-context', '~> 1.2'
end
