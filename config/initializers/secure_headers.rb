::SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{20.years.to_i}; includeSubdomains"
  config.csp = {
    :default_src => ["'self'"],
    :child_src   => ["'self'"],
    :connect_src => ["'self'", 'ws:', 'wss:'],
    :style_src   => ["'unsafe-inline'", "'self'"],
    :script_src  => ["'unsafe-eval'", "'unsafe-inline'", "'self'"],
    :img_src     => ["'self'", 'data:', '*.gravatar.com']
  }
end
