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
  # Default: no Clear-Site-Data header
  config.clear_site_data = SecureHeaders::OPT_OUT
end

# Configuration override for logout actions - clears browser cache, cookies, and storage
::SecureHeaders::Configuration.override(:logout_clear_data) do |override|
  override.clear_site_data = %w[cache cookies storage]
end
