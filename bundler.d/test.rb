group :test do
  gem 'mocha', '~> 1.11'
  gem 'single_test', '~> 0.6'
  gem 'minitest', '~> 5.1', '< 5.11'
  gem 'minitest-retry', '~> 0.0', :require => false
  gem 'minitest-spec-rails', '~> 6.0'
  gem 'ci_reporter_minitest', :require => false
  gem 'capybara', '~> 3.0', '< 3.32.1', :require => false
  gem 'puma', '~> 5.1', :require => false
  gem 'show_me_the_cookies', '~> 5.0', :require => false
  gem 'database_cleaner', '~> 1.3', :require => false
  gem 'launchy', '~> 2.4'
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
