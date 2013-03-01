group :development do
  # To use debugger
  gem "ruby-debug", :platforms => :ruby_18, :require => false
  gem "ruby-debug19", :platforms => :ruby_19, :require => false
  gem 'maruku'
  gem 'single_test'
  gem 'pry'
  gem "term-ansicolor"
#  gem 'rack-mini-profiler'

  # for generating i18n files
  gem 'gettext', '>= 1.9.3', :require => false
end
