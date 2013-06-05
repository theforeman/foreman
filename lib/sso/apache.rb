module SSO
  class Apache < Base
    CAS_USERNAME = 'REMOTE_USER'
    def available?
      return false unless Setting['authorize_login_delegation']
      return false if controller.api_request? and not Setting['authorize_login_delegation_api']
      true
    end

    # If REMOTE_USER is provided by the web server then
    # authenticate the user without using password.
    def authenticated?
      (self.user = request.env[CAS_USERNAME]).present?
    end
  end
end