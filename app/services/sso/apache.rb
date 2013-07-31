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

    # If REMOTE_USER is provided by the web server then
    # authenticate the user without using password.
    def authenticated?
      self.user = request.env[CAS_USERNAME]
      store
      true
    end

    def logout_url
      "#{Setting['login_delegation_logout_url']}"
    end

    def store
      session[:sso_method] = self.class.to_s
    end

  end
end
