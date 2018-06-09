# This file is used by Rack-based servers to start the application.
require 'rack'

# load Rails environment
require ::File.expand_path('../config/environment', __FILE__)

# apply a prefix to the application, if one is defined
# e.g. http://some.server.com/prefix where '/prefix' is defined by env variable
map ENV['RAILS_RELATIVE_URL_ROOT'] || '/' do
  run Foreman::Application
end
