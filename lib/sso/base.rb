module SSO
  class Base
    attr_reader :controller
    attr_accessor :user
    delegate :request, :to => :controller

    def initialize(controller)
      @controller = controller
    end

    def support_login?
      false
    end

    # don't forget to implement expiration_url method if your SSO method changes this to true
    def support_expiration?
      false
    end

    # if your SSO method supports logout page, you should store it into a session[:logout_url]
    # during this method execution
    def authenticated?
      raise NotImplemented, 'authenticated? not implemented for this authentication method'
    end

    def authenticate!
      raise NotImplemented, 'authenticate! not implemented for this authentication method'
    end
  end
end
