group :test do
  gem 'mocha', '< 0.13.0', :require => false
  gem 'shoulda', "=3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'single_test'
  gem 'ci_reporter', '>= 1.6.3'
end
