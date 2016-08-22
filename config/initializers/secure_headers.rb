::SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{20.years.to_i}; includeSubdomains"
  config.csp = {
    :default_src => %w('self'),
    :child_src   => %w('self'),
    :connect_src => %w('self' ws: wss:),
    :style_src   => %w('unsafe-inline' 'self'),
    :script_src  => %w('unsafe-eval' 'unsafe-inline' 'self'),
    :img_src     => %w('self' *.gravatar.com)
  }
end
