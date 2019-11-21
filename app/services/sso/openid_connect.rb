module SSO
  class OpenidConnect < Base
    delegate :session, :to => :controller
    attr_reader :current_user

    def available?
      ((controller.api_request? && bearer_token_set?) || http_token.present?) && valid_issuer?
    end

    def authenticate!
      payload = jwt_token.decode
      return nil if payload.nil?
      user = find_or_create_user_from_jwt(payload)
      @current_user = user
      update_session(payload)
      user&.login
    end

    def authenticated?
      self.user = User.current.presence || authenticate!
    end

    def logout_url
      Setting['login_delegation_logout_url']
    end

    private

    def jwt_token
      @jwt_token ||= jwt_token_from_request
    end

    def jwt_token_from_request
      token = (request.authorization.present? && request.authorization.split(' ')[1]) ||
        http_token
      OidcJwt.new(token)
    end

    def bearer_token_set?
      request.authorization.present? && request.authorization.start_with?('Bearer')
    end

    def valid_issuer?
      payload = jwt_token.decoded_payload
      payload.key?('iss') && (payload['iss'] == Setting['oidc_issuer'])
    end

    def update_session(payload)
      session[:sso_method] = self.class.to_s
      session[:expires_at] = payload['exp']
      session[:logout_url] = logout_url
    end

    def find_or_create_user_from_jwt(payload)
      User.find_or_create_external_user(
        { login: payload['preferred_username'],
          mail: payload['email'],
          firstname: payload['given_name'],
          lastname: payload['family_name']},
        Setting['authorize_login_delegation_auth_source_user_autocreate']
      )
    end
  end
end
