require 'open3'

class PortInUse < StandardError; end

class VNCProxy
  attr_accessor :host, :host_port, :password, :timeout
  attr_reader :proxy_port

  # Allowed ports to communicate with our web sockets proxy
  PORTS = 5910..5930

  def initialize(attributes)
    # setup all attributes.
    defaults.merge(attributes).each do |k, v|
      eval("self.#{k}= v") if self.respond_to?("#{k}=")
    end
  end

  def self.start attributes
    proxy = VNCProxy.new(attributes)
    proxy.start_proxy
  end

  def start_proxy

    # try to execute our web sockets proxy
    port = PORTS.first
    begin
      cmd  = "#{ws_proxy} --daemon --run-once --timeout=#{timeout} #{port} #{host}:#{host_port}"
      execute(cmd)
      # if the port is already in use, try another one from the pool
      # this is not ideal, as it would try all ports in order
      # but it avoids any threading issues etc.
      # TODO: try to select a port from a pool randomly, so we always hit all active connections.
    rescue PortInUse
      port += 1
      retry if port <= PORTS.last
    end
    @proxy_port = port

    { :host => host, :port => host_port, :password => password, :proxy_port => proxy_port }
  end

  private

  def ws_proxy
    "#{Rails.root}/extras/noVNC/wsproxy.py"
  end

  def defaults
    {
      :timeout   => 120,
      :host_port => 5900,
      :host      => "0.0.0.0",
    }
  end

  def logger
    Rails.logger
  end

  def execute cmd

    logger.debug "Starting VNC Proxy: #{cmd}"
    Open3::popen3(cmd) do |stdin, stdout, stderr|
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
