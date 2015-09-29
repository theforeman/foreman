group :fog do
 gem 'fog', '~> 1.24.0'
 gem 'fog-core', '~> 1.24.0'
 gem 'unf'
 gem 'net-ssh', '< 3' if RUBY_VERSION.start_with? '1.9.'
end
