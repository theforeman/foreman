# This file is used by Rack-based servers to start the application.

require 'rack'
require './lib/foreman/telemetry_rack'
require 'prometheus/middleware/exporter'

# load Rails environment
require ::File.expand_path('../config/environment',  __FILE__)

use Foreman::TelemetryRack
if defined?(Prometheus::Middleware::Exporter) && SETTINGS[:telemetry].try(:fetch, :prometheus).try(:fetch, :enabled)
  use Prometheus::Middleware::Exporter
end

# apply a prefix to the application, if one is defined
# e.g. http://some.server.com/prefix where '/prefix' is defined by env variable
map ENV['RAILS_RELATIVE_URL_ROOT'] || '/'  do
  run Foreman::Application
end
