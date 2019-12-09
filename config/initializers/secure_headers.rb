::SecureHeaders::Configuration.default do |config|
  if SETTINGS[:hsts_enabled]
    config.hsts = "max-age=#{20.years.to_i}; includeSubdomains"
  else
    config.hsts = "max-age=0; includeSubdomains"
  end
  config.csp = {
    :default_src => ["'self'"],
    :child_src   => ["'self'"],
    :connect_src => ["'self'", 'ws:', 'wss:'],
    :style_src   => ["'unsafe-inline'", "'self'"],
    :script_src  => ["'unsafe-eval'", "'unsafe-inline'", "'self'"],
    :img_src     => ["'self'", 'data:'],
  }
end
