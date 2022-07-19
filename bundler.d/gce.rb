group :gce do
  gem 'fog-google', '~> 1.14'

  # https://projects.theforeman.org/issues/35244 Not a direct dependency, but
  # indirect. The ecosystem is incompatible with 2.x so pin to 1.x
  gem 'faraday', '< 2'
end
