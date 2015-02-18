module SSO
  class Basic < Base
    def available?
      controller.api_request? && http_auth_set?
    end

    def authenticate!
      user = controller.authenticate_with_http_basic do |u, p|
        self.user = u
        User.try_to_login(u, p)
      end

      self.user = user.login if user.present?
    end

    def authenticated?
      User.current.present? ? User.current.login : authenticate!
    end

    def http_auth_set?
      request.authorization.present? && request.authorization =~ /\ABasic/
    end
  end
end
