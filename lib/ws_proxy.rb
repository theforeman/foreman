class WsProxy
  def self.token(host, port, algorithm: 'RS512')
    # TODO: fail if no websockets_ssl_key
    jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(File.read((Setting[:websockets_ssl_key]))))
    payload = { host: host, port: port }
    headers = { kid: jwk.kid }

    JWT.encode(payload, jwk.keypair, algorithm, headers)
  end

  def self.encrypt?
    Setting[:websockets_encrypt]
  end

  def self.scheme
    encrypt? ? 'wss' : 'ws'
  end

  def self.proxy_host
    URI.parse(Setting[:foreman_url]).host
  end

  def self.proxy_port
    5910 # TODO configurable
  end

  # TODO: not really start anymore
  def self.start(host:, host_port:, password:)
    token = token(host, host_port)
    { scheme: scheme, host: proxy_host, port: proxy_port, password: password, token: token, encrypt: encrypt? }
  end
end
