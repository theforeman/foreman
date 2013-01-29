group :test do
  gem 'mocha', '>= 0.13.2', :require => 'mocha/api'
  gem 'shoulda', "=3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'single_test'
  gem 'ci_reporter', '>= 1.6.3'
  gem 'minitest', '~> 3.5', :platforms => :ruby_19
end
