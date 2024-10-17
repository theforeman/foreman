group :libvirt do
  # gem 'fog-libvirt', '>= 0.12.0'
  gem 'ruby-libvirt', '~> 0.5', :require => 'libvirt'
  # TODO: Remove this line after merging the PR
  gem 'fog-libvirt', github: 'nofaralfasi/fog-libvirt', branch: 'sb_libvirt'
end
