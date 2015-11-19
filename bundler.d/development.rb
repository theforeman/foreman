group :development do
  gem 'maruku', '~> 0.7'
  gem 'rubocop', '0.35.1'

  # for generating i18n files
  gem 'gettext', '~> 3.1', :require => false

  # for generating foreign key migrations
  gem 'immigrant', '~> 0.1'

  gem 'pry'
  gem 'term-ansicolor'
  gem 'tins', '< 1.7.0', :require => false if RUBY_VERSION.start_with? '1.9.'

  gem 'bullet'
  gem "parallel_tests"
end
