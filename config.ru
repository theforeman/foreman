# This file is used by Rack-based servers to start the application.
require 'rack'

# load Rails environment
require ::File.expand_path('../config/environment', __FILE__)

map '/' do
  run Foreman::Application
end
