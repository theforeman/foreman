group :development do
  gem 'maruku', '~> 0.7'
  gem 'term-ansicolor'
  gem 'rubocop', '0.26.1'

  # for generating i18n files
  gem 'gettext', '~> 3.1', :require => false
  gem 'locale', '~> 2.0'

  # for generating foreign key migrations
  gem 'immigrant', '~> 0.1'

  gem 'pry'
  gem 'bullet'
end
