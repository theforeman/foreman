group :vmware do
  # With 3.6.1 test/controllers/api/v2/hosts_controller_test is failing
  gem 'fog-vsphere', '~> 3.6', '!= 3.6.1'
end
