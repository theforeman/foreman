group :development do
  # To use debugger
  case RUBY_VERSION
  when /^1\.8/
    gem "ruby-debug", :platforms => :ruby_18, :require => false
  when /^1\.9/
    gem "ruby-debug19", :platforms => :ruby_19, :require => false
  end
  gem 'maruku'
  gem 'single_test'
  gem 'pry'
  gem "term-ansicolor"
#  gem 'rack-mini-profiler'

  # for generating i18n files
  gem 'gettext', '>= 1.9.3', :require => false
end
