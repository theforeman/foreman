group :test do
  gem 'mocha', '~> 1.1'
  gem 'single_test', '~> 0.6'
  gem 'minitest', '~> 5.1', '< 5.11'
  gem 'minitest-optional_retry', '~> 0.0', :require => false
  gem 'minitest-spec-rails', '~> 5.3'
  gem 'ci_reporter_minitest', :require => false
  gem 'capybara', '~> 2.5', :require => false
  gem 'show_me_the_cookies', '~> 3.0', :require => false
  gem 'database_cleaner', '~> 1.3', :require => false
  gem 'launchy', '~> 2.4'
  gem 'factory_girl_rails', '~> 4.8.0', :require => false
  gem 'rubocop-checkstyle_formatter', '~> 0.2'
  gem "poltergeist", :require => false
  gem 'shoulda-matchers', '~> 3.0'
  gem 'shoulda-context', '~> 1.2'
  gem 'as_deprecation_tracker', '~> 1.4'
  case SETTINGS[:rails]
  when '4.2'
    gem 'test_after_commit', '>= 0.4', '< 2.0'
  when '5.0'
    gem 'rails-controller-testing', '~> 1.0'
  end
  if RUBY_VERSION < '2.2'
    gem 'xpath', '< 3'
  end
end
