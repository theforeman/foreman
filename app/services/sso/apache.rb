module SSO
  class Apache < Base
    delegate :session, :to => :controller

    CAS_USERNAME = 'REMOTE_USER'
    def available?
      return false unless Setting['authorize_login_delegation']
      return false if controller.api_request? and not Setting['authorize_login_delegation_api']
      return false if controller.api_request? and not request.env[CAS_USERNAME].present?
      true
    end

    def support_expiration?
      true
    end

    def support_fallback?
      true
    end

    # If REMOTE_USER is provided by the web server then
    # authenticate the user without using password.
    def authenticated?
      return false unless (self.user = request.env[CAS_USERNAME])
      store
      true
    end

    def support_login?
      request.fullpath != self.login_url
    end

    def authenticate!
      self.has_rendered = true
      controller.redirect_to controller.extlogin_users_path
    end

    def login_url
      controller.extlogin_users_path
    end

    def logout_url
      Setting['login_delegation_logout_url'] || controller.extlogout_users_path
    end

    def expiration_url
      controller.extlogin_users_path
    end

    def store
      session[:sso_method] = self.class.to_s
    end

  end
end
