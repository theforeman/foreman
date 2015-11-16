group :fog do
  gem 'fog', '1.36.0', :require => false
  gem 'fog-core', '1.34.0'
  if RUBY_VERSION.start_with? '1.9.'
    gem 'net-ssh', '< 3'
  else
    gem 'net-ssh'
  end
  gem 'net-scp'
end
