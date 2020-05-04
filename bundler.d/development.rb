group :development do
  gem 'maruku', '~> 0.7'

  # for generating i18n files
  gem 'gettext', '>= 3.2.1', ((RUBY_VERSION < '2.5') ? '< 3.3.0' : '< 4.0.0'), :require => false

  # for generating foreign key migrations
  gem 'immigrant', '~> 0.1'

  gem 'pry'

  gem 'bullet', '>= 5.7.3'
  gem "parallel_tests"
  gem 'spring', '>= 1.0', ((RUBY_VERSION < '2.4') ? '< 2.1.0' : '< 3')
  gem 'benchmark-ips', '>= 2.8.2'
  gem 'foreman'
  gem('bootsnap', :require => false)
  gem 'graphiql-rails', '~> 1.7'
end
