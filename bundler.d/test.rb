group :test do
  gem 'mocha', :require => false
  gem 'shoulda', "=3.0.1"
  gem 'rr'
  gem 'rake'
  gem 'single_test'
  gem "ruby-debug", :platforms => :ruby_18
  gem "ruby-debug19", :platforms => :ruby_19
end
