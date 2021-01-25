run_dir = Rails.root.join('tmp')

# Store server info state.
state_path File.join(run_dir, 'puma.state')
state_permission 0o0640

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

# In clustered mode, Puma can "preload" your application. This loads all the
# application code prior to forking. Preloading reduces total memory usage of
# your application via an operating system feature called copy-on-write
#
preload_app!

# When systemd socket activation is detected, only use those sockets. This
# makes FOREMAN_BIND redundant. The code is still there for non-systemd
# deployments.
bind_to_activated_sockets 'only'

# Check if FOREMAN_BIND was set to an IP address based on the previous
# definition of FOREMAN_BIND. If it is an IP address, define the host
# and port through Puma's DSL. Otherwise rescue and assume the new
# style of a fully specified bind in the formats of:
#
#  * unix:///run/foreman.sock
#  * tcp://127.0.0.1:3000
#
begin
  IPAddr.new(ENV['FOREMAN_BIND'])

  port ENV.fetch('FOREMAN_PORT', '3000'), ENV['FOREMAN_BIND']
rescue IPAddr::Error
  bind ENV.fetch('FOREMAN_BIND', 'tcp://127.0.0.1:3000')
end

on_worker_boot do
  dynflow = ::Rails.application.dynflow
  dynflow.initialize! unless dynflow.config.lazy_initialization
end

# === Puma control rack application ===
activate_control_app "unix://#{run_dir}/sockets/pumactl.sock"

# Loading and initializing of all gettext languages takes about 100ms per language
# in development environment and little less on production. Let's eager load languages
# for production before forking to save memory on CoW operating systems.
before_fork do
  FastGettext.human_available_locales
end
