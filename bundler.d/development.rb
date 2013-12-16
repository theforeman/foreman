group :development do
  gem 'maruku'
  gem 'pry'
  gem "term-ansicolor"
#  gem 'rack-mini-profiler'

  # for generating i18n files
  gem 'gettext', '~> 2.0', :require => false
  gem 'locale', '<= 2.0.9'

  # for generating foreign key migrations
  gem 'immigrant'
end
