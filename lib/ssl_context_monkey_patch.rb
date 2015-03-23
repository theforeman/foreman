require 'openssl'

# we need to enforce verify_mode => 1 on SSL context
# more info in http://projects.theforeman.org/issues/9858
class OpenSSL::SSL::SSLContext
  def initialize_with_ssl_verify_mode(*args)
    initialize_without_ssl_verify_mode(*args)
    params = { :options => DEFAULT_PARAMS[:options] }
    set_params(params)
  end

  alias_method_chain :initialize, :ssl_verify_mode
end
