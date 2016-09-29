module SSO
  class Base
    attr_reader :controller
    attr_accessor :user, :has_rendered
    delegate :request, :to => :controller

    def initialize(controller)
      @controller = controller
    end

    def support_login?
      false
    end

    def support_fallback?
      false
    end

    # Override this value on SSO objects to redirect your users to a custom auth path
    def login_url
      controller.main_app.login_users_path
    end

    def logout_url
      nil
    end

    # don't forget to implement expiration_url method if your SSO method changes this to true
    def support_expiration?
      false
    end

    # if your SSO method supports logout page, you should store it into a session[:logout_url]
    # during this method execution
    def authenticated?
      raise NotImplementedError, "#{__method__} not implemented for this authentication method"
    end

    def authenticate!
      raise NotImplementedError, "#{__method__} not implemented for this authentication method"
    end

    def current_user
      User.except_hidden.find_by_login(self.user)
    end
  end
end
