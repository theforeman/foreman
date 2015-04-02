group :development do
  gem 'maruku', '~> 0.7'
  gem 'term-ansicolor'
  gem 'rubocop', '0.28.0'

  # for generating i18n files
  gem 'gettext', '~> 3.1', :require => false

  # for generating foreign key migrations
  gem 'immigrant', '~> 0.1'

  gem 'pry'
  gem 'bullet'
  gem "parallel_tests"
end
