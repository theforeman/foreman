group :gce do
  gem 'fog-google', '<= 0.1.0'
  gem 'google-api-client', '>= 0.7', '< 0.9', :require => 'google/api_client'
  gem 'sshkey', '~> 1.3'
  gem 'jwt', '< 1.5.3'
end
