group :test do
  gem 'mocha', '= 0.12.8', :require => false
  gem 'minitest', '~> 3.5', :platforms => :ruby_19
  gem 'single_test'
  gem 'shoulda', "=3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'ci_reporter', '>= 1.6.3'
end
