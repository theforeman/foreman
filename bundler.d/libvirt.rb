group :libvirt do
  gem 'fog-libvirt', github: 'ekohl/fog-libvirt', branch: 'implement-efi'
  gem 'ruby-libvirt', '~> 0.5', :require => 'libvirt'
end
