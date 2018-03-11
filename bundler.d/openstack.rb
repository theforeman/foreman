group :openstack do
  gem 'fog-openstack', '>= 0.1.11', (RUBY_VERSION < '2.1' ? '< 0.1.23' : '< 1')
end
