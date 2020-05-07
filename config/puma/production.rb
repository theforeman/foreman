run_dir = Rails.root.join('tmp')

# Store server info state.
state_path File.join(run_dir, 'puma.state')
state_permission 0640

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
#
# The default is "0, 16".
#
threads ENV.fetch('FOREMAN_PUMA_THREADS_MIN', 0).to_i, ENV.fetch('FOREMAN_PUMA_THREADS_MAX', 16).to_i

# === Cluster mode ===

# How many worker processes to run.
#
# The default is "0" for puma. Recommending "2" for foreman
#
workers ENV.fetch('FOREMAN_PUMA_WORKERS', 2).to_i

on_worker_boot do
  dynflow = ::Rails.application.dynflow
  dynflow.initialize! unless dynflow.config.lazy_initialization
end

# === Puma control rack application ===
activate_control_app "unix://#{run_dir}/sockets/pumactl.sock"
