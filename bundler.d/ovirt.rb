group :ovirt do
  gem 'fog-ovirt', '~> 1.2.0'
  if RUBY_VERSION < '2.5'
    gem 'ovirt-engine-sdk', '< 4.4.0'
  end
end
