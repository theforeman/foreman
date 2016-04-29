group :console do
  if RUBY_VERSION.start_with? '1.9.'
    gem 'wirb', '~> 1.0'
  else
    gem 'wirb', '>= 1.0', '< 3.0'
  end
  gem 'hirb-unicode', '~> 0.0.5'
  gem 'awesome_print', '~> 1.0', :require => 'ap'
end
