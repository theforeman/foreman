group :gce do
  gem 'fog-google', '<= 0.1.0'
  gem 'google-api-client', '~> 0.8.2', :require => 'google/api_client'
  if RUBY_VERSION < '2.1'
    gem 'jwt', '< 2'
  end
end
