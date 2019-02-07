group :development do
  gem 'maruku', '~> 0.7'
  gem 'rubocop', '~> 0.59.2'

  # for generating i18n files
  gem 'gettext', '>= 3.2.1', '< 4.0.0', :require => false

  # for generating foreign key migrations
  gem 'immigrant', '~> 0.1'

  gem 'pry'

  gem 'bullet', '>= 5.7.3'
  gem "parallel_tests"
  gem 'spring', '>= 1.0', '< 3'
  gem 'benchmark-ips'
  gem 'foreman'
  gem('bootsnap', :require => false)
  gem 'graphiql-rails', '~> 1.7'
end
