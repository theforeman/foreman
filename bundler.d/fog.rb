group :fog do
  gem 'fog', '1.34.0', :require => false
  gem 'fog-core', '1.32.1'
  gem 'net-ssh', '< 3' if RUBY_VERSION.start_with? '1.9.'
end
