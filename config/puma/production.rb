require 'English'

# Puma will only listen on what it's configured to listen on. When running
# under systemd socket activation, the configuration where to listen is in
# foreman.socket. This code translates whatever listen file descriptors it
# received from systemd into bind statements. It also clears anything it was
# configured on.
if ENV['LISTEN_FDS'] && ENV['LISTEN_PID'].to_i == $PID
  require 'socket'

  clear_binds!

  ENV['LISTEN_FDS'].to_i.times do |index|
    fd = index + 3 # 3 is the magic number you add to follow the SA protocol
    sock = TCPServer.for_fd(fd)
    url = begin # Try to parse as a path
            "unix://#{Socket.unpack_sockaddr_un(sock.getsockname)}"
          rescue ArgumentError # Try to parse as a port/ip
            port, addr = Socket.unpack_sockaddr_in(sock.getsockname)
            addr = "[#{addr}]" if addr =~ /\:/
            "tcp://#{addr}:#{port}"
          end

    bind url
  end
end

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

# Provides systemd notify support through the
# puma-systemd-plugin
begin
  plugin :systemd
rescue Puma::UnknownPlugin
  puts "Failed to load systemd plugin"
end

# In clustered mode, Puma can "preload" your application. This loads all the
# application code prior to forking. Preloading reduces total memory usage of
# your application via an operating system feature called copy-on-write
#
preload_app!

on_worker_boot do
  dynflow = ::Rails.application.dynflow
  dynflow.initialize! unless dynflow.config.lazy_initialization
end
