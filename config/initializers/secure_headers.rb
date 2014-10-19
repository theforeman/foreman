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
    :connect_src => 'self ws://',
    :style_src   => 'inline self',
    :script_src  => 'eval inline self',
    :img_src     => ['self', '*.gravatar.com']
  }
end
