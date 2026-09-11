group :test do
  gem 'mocha', '~> 2.1'
  gem 'minitest', '~> 5.1'
  gem 'minitest-reporters', '~> 1.4', :require => false
  gem 'minitest-retry', '~> 0.0', :require => false
  gem 'minitest-spec-rails', '~> 7.1'
  gem 'minitest_reporters_github', '~> 1.0', :require => false
  gem 'capybara', '~> 3.33', :require => false
  gem 'show_me_the_cookies', '~> 6.0', :require => false
  # database_cleaner (< 2.0, deprecated) references ActiveRecord::SchemaMigration
  # directly, which no longer works as of Rails 7.1's per-connection schema
  # migration tracking; database_cleaner-active_record is the maintained successor.
  gem 'database_cleaner-active_record', '~> 2.2', :require => false
  gem 'launchy', '~> 2.4'
  gem 'facterdb', '~> 1.7'
  gem 'factory_bot_rails', '~> 5.0', :require => false
  gem 'selenium-webdriver', :require => false
  gem 'shoulda-matchers', '~> 5.0'
  gem 'shoulda-context', '~> 1.2'
  # TEMPORARY: pinned to our fork/branch pending https://github.com/domcleal/as_deprecation_tracker/pull/5
  # (Rails 7.1 support) being merged and released. Revert to the plain version
  # constraint (gem 'as_deprecation_tracker', '~> 1.6') once a release containing
  # that fix is out.
  gem 'as_deprecation_tracker', git: 'https://github.com/lhellebr/as_deprecation_tracker', branch: 'rails-7.1-deprecators-compat'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rfauxfactory', '~> 0.1', '>= 0.1.5'
  gem 'robottelo_reporter', '~> 0.1'
  gem 'theforeman-rubocop', '~> 0.1.2', require: false
  gem 'webmock'
end
