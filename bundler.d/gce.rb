group :gce do
  gem 'fog-google', '~> 1.8.2'
  if RUBY_VERSION < '2.4'
    gem 'signet', '< 0.12'
  end
end
