::SecureHeaders::Configuration.configure do |config|
  config.hsts = {
    :max_age            => 20.years.to_i,
    :include_subdomains => true
  }
  config.x_frame_options = 'SAMEORIGIN'
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = {
    :value => 1,
    :mode  => 'block'
  }
  config.csp = {
    :enforce     => true,
    :default_src => 'self',
    :frame_src   => 'self',
    :connect_src => %w(self ws: wss:),
    :style_src   => 'inline self',
    :script_src  => %w(eval inline self),
    :img_src     => %w(self *.gravatar.com)
  }
  if Rails.env.development? #allow webpack dev server provided assets
    dev_server = ["http://0.0.0.0:#{::Rails.configuration.webpack.dev_server.port}",
                  "http://localhost:#{::Rails.configuration.webpack.dev_server.port}"]
    config.csp[:script_src] += dev_server
    config.csp[:connect_src] += dev_server
  end
end
