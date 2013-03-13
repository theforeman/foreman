begin
  require 'rack/openid'
  Rails.configuration.middleware.use Rack::OpenID
rescue LoadError
  nil
end
