begin
  require 'rack/openid'
  require 'openid/store/filesystem'
  openid_store_path = Pathname.new(Rails.root).join('db').join('openid-store')
  Rails.configuration.middleware.use Rack::OpenID, OpenID::Store::Filesystem.new(openid_store_path)
rescue LoadError
  nil
end
