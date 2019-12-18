# Set multiprocess-friendly data store
require 'prometheus/client'
require 'prometheus/client/data_stores/direct_file_store'
PROMETHEUS_STORE_DIR = File.join(Rails.root, 'tmp', 'prometheus')
FileUtils.mkdir_p(PROMETHEUS_STORE_DIR)
Prometheus::Client.config.data_store =
  Prometheus::Client::DataStores::DirectFileStore.new(dir: PROMETHEUS_STORE_DIR)

# Foreman telemetry global setup.
telemetry = Foreman::Telemetry.instance
if SETTINGS[:telemetry] && (Rails.env.production? || Rails.env.development?)
  telemetry.setup(SETTINGS[:telemetry])
end

# Register Rails notifications metrics
telemetry.register_rails

# Register Ruby VM metrics
telemetry.register_ruby
