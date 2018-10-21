group :test do
  gem 'mocha', '~> 1.4'
  gem 'single_test', '~> 0.6'
  gem 'minitest', '~> 5.1', '< 5.11'
  gem 'minitest-retry', '~> 0.0', :require => false
  gem 'minitest-spec-rails', '~> 5.3'
  gem 'ci_reporter_minitest', :require => false
  gem 'capybara', '~> 3.0', :require => false
  gem 'puma', :require => false
  gem 'show_me_the_cookies', '~> 4.0', :require => false
  gem 'database_cleaner', '~> 1.3', :require => false
  gem 'launchy', '~> 2.4'
  gem 'factory_bot_rails', '~> 4.5', :require => false
  gem 'rubocop-checkstyle_formatter', '~> 0.2'
  gem 'poltergeist', '>= 1.18.0', :require => false
  gem 'selenium-webdriver', :require => false
  gem 'shoulda-matchers', '~> 3.0'
  gem 'shoulda-context', '~> 1.2'
  gem 'as_deprecation_tracker', '~> 1.4'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rfauxfactory', '~> 0.1'
  gem 'robottelo_reporter', '~> 0.1'
  gem 'webmock'
end
