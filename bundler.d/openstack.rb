group :openstack do
  gem 'fog-openstack', '>= 0.1.11', (RUBY_VERSION < '2.2' ? '< 0.1.26' : '< 1.0')
end
