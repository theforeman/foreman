require 'openssl'
require 'socket'

class GetRawCertificate
  def initialize(remote_host, port)
    ctx = OpenSSL::SSL::SSLContext.new
    sock = TCPSocket.new(remote_host, port)
    @ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
    @ssl.connect
  end

  def cert
    @ssl.peer_cert
  end
end
