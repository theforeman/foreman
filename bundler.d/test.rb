group :test do
  gem 'mocha', '~> 1.1', :require => false
  gem 'simplecov', '~> 0.9'
  gem 'spork-minitest', '0.0.3'
  gem 'single_test', '~> 0.6'
  gem 'minitest', '~> 5.1'
  gem 'minitest-spec-rails' #, '~> 4.7'
  gem 'ci_reporter', '>= 1.6.3', '< 2.0.0', :require => false
  gem 'capybara', '~> 2.0'
  gem 'database_cleaner', '~> 1.3'
  gem 'launchy', '~> 2.4'
  gem 'spork', '~> 0.9'
  gem 'factory_girl_rails', '~> 4.5', :require => false
  gem 'rubocop-checkstyle_formatter', '~> 0.1'
  gem "poltergeist"
end
