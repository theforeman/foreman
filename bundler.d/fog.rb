group :fog do
  gem 'fog', '1.29.0'
  gem 'fog-core', '1.29.0'
  gem 'net-ssh', '< 3' if RUBY_VERSION.start_with? '1.9.'
end
