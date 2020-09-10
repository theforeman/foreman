require 'open3'
require 'socket'
require 'timeout'

class PortInUse < StandardError; end

class WsProxy
  attr_accessor :host, :host_port, :password, :timeout, :idle_timeout, :ssl_target
  attr_reader :proxy_port

  # Allowed ports to communicate with our web sockets proxy
  PORTS = 5910..5930

  def initialize(attributes)
    # setup all attributes.
    defaults.merge(attributes).each do |k, v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
  end

  def self.start(attributes)
    proxy = WsProxy.new(attributes)
    proxy.start_proxy
  end

  def free_port?(port)
    socket = Socket.new :INET, :STREAM
    socket.bind(Socket.pack_sockaddr_in(port, '127.0.0.1'))
    true
  rescue Errno::EADDRINUSE
    false
  ensure
    socket&.close
  end

  def start_proxy
    # randomly preselect free tcp port from the range
    port = 0
    Timeout.timeout(5) do
      until free_port?(port = rand(PORTS)); end
    end
    # execute websockify proxy
    begin
      cmd  = "#{ws_proxy} --daemon --idle-timeout=#{idle_timeout} --timeout=#{timeout} #{port} #{host}:#{host_port}"
      cmd += " --ssl-target" if ssl_target
      if Setting[:websockets_encrypt]
        cmd += " --cert #{Setting[:websockets_ssl_cert]}" if Setting[:websockets_ssl_cert]
        cmd += " --key #{Setting[:websockets_ssl_key]}" if Setting[:websockets_ssl_key]
      end
      execute(cmd)
    rescue PortInUse
      # fallback just in case of race condition
      port += 1
      if port >= PORTS.last
        raise ::Foreman::Exception.new(N_('No free ports available for websockify, try again later'))
      else
        retry
      end
    end
    @proxy_port = port
    { :port => proxy_port, :password => password, :encrypt => @encrypt }
  end

  private

  def ws_proxy
    "#{Rails.root}/extras/noVNC/websockify.py"
  end

  def defaults
    {
      :timeout      => 120,
      :idle_timeout => 120,
      :host_port    => 5900,
      :host         => "0.0.0.0",
    }
  end

  def logger
    Rails.logger
  end

  def execute(cmd)
    logger.debug "Starting VNC Proxy: #{cmd}"
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      stdout.each do |line|
        logger.debug "[#{line}"
      end
      stderr.each do |line|
        logger.debug "VNCProxy Error: #{line}"
        raise PortInUse if line["socket.error: [Errno 98] Address already in use"]
      end
    end
  end
end
