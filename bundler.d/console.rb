group :console do
  gem 'wirb', '~> 1.0'
  gem 'hirb-unicode', '~> 0.0.5'
  gem 'awesome_print', '~> 1.0', :require => 'ap'

  # minitest - workaround until Rails 4.0 (#2650)
  gem 'minitest', '~> 4.7', :require => 'minitest/unit'
end
