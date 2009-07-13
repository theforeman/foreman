# Prefer gems to the bundled libs.
require 'rubygems'

begin
  gem 'builder', '~> 2.1.2'
rescue Gem::LoadError
  $:.unshift "#{File.dirname(__FILE__)}/vendor/builder-2.1.2"
end
require 'builder'

begin
  gem 'memcache-client', '>= 1.6.5'
rescue Gem::LoadError
  $:.unshift "#{File.dirname(__FILE__)}/vendor/memcache-client-1.6.5"
end

begin
  gem 'tzinfo', '~> 0.3.12'
rescue Gem::LoadError
  $:.unshift "#{File.dirname(__FILE__)}/vendor/tzinfo-0.3.12"
end

# TODO I18n gem has not been released yet
# begin
#   gem 'i18n', '~> 0.1.3'
# rescue Gem::LoadError
  $:.unshift "#{File.dirname(__FILE__)}/vendor/i18n-0.1.3/lib"
  require 'i18n'
# end
