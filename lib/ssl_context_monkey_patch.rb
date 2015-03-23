require 'openssl'

# we need to enforce verify_mode => 1 on SSL context
# more info in http://projects.theforeman.org/issues/9858
class OpenSSL::SSL::SSLContext
  alias __original_initialize initialize
  private :__original_initialize

  def initialize(*args)
      __original_initialize(*args)
      params = {
        :options => DEFAULT_PARAMS[:options],
      }
      set_params(params)
    end
end
