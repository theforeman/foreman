group :development do
  # To use debugger
  gem "ruby-debug", :platforms => :ruby_18
  gem "ruby-debug19", :platforms => :ruby_19
  gem 'redcarpet', '<= 2.1.0'
  gem 'single_test'
  gem 'pry'
  gem "term-ansicolor"
  gem 'rack-mini-profiler'
end
