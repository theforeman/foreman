group :test do
  gem 'mocha', '~> 1.11'
  gem 'single_test', '~> 0.6'
  gem 'minitest', '~> 5.1'
  gem 'minitest-reporters', '~> 1.4', :require => false
  gem 'minitest-retry', '~> 0.0', :require => false
  gem 'minitest-spec-rails', '~> 6.0'
  gem 'capybara', '~> 3.33', :require => false
  gem 'show_me_the_cookies', '~> 5.0', :require => false
  gem 'database_cleaner', '~> 1.3', :require => false
  gem 'launchy', '~> 2.4'
  gem 'facterdb', '~> 1.7'
  gem 'factory_bot_rails', '~> 5.0', :require => false
  gem 'selenium-webdriver', :require => false
  gem 'shoulda-matchers', '>= 4.0', '< 4.4'
  gem 'shoulda-context', '~> 1.2'
  gem 'as_deprecation_tracker', '~> 1.4'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rfauxfactory', '~> 0.1', '>= 0.1.5'
  gem 'robottelo_reporter', '~> 0.1'
  gem 'theforeman-rubocop', '~> 0.0.6', require: false
  gem 'webmock'
end
