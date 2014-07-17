group :fog do
 gem 'fog', '~> 1.21.0'
 gem 'fog-core', '~> 1.21.0'
 gem 'fog-json', '1.0.0' # Should be pulled in, but jenkins isn;t for some reason. TODO: investigate why
 gem 'fog-brightbox', '0.0.2' # ditto
 gem 'unf'
end
