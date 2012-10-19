group :test do
  if RUBY_VERSION >= '1.9.3'
    gem 'mocha', :require => false
  else
    gem 'mocha', '< 0.13.0', :require => false
  end
  gem 'shoulda', "=3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'single_test'
  gem 'ci_reporter', '>= 1.6.3'
  gem "minitest", :platforms => :ruby_19
end
