group :libvirt do
  gem 'fog-libvirt', github: 'ekohl/fog-libvirt', branch: 'force-test-urls'
  gem 'ruby-libvirt', '~> 0.5', :require => 'libvirt'
end
