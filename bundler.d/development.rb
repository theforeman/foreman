group :development do
  gem 'maruku'
  gem "term-ansicolor"
  if RUBY_VERSION =~ /^1\.9|^2/
    gem 'rubocop', '0.26.1'
  end
#  gem 'rack-mini-profiler'

  # for generating i18n files
  gem 'gettext', '~> 2.0', :require => false
  gem 'locale', '<= 2.0.9'

  # for generating foreign key migrations
  gem 'immigrant'

  # pry has dropped support for 1.8
  if RUBY_VERSION =~ /^1\.8/
    gem 'pry', '< 0.10.0'
  else
    gem 'pry'
  end
end
