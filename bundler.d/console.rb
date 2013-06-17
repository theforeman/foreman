group :console do
  gem 'wirb'
  gem 'hirb-unicode'
  gem 'awesome_print', :require => 'ap'

  # minitest - workaround until Rails 4.0 (#2650)
  gem 'minitest', '~> 4.7'
end
