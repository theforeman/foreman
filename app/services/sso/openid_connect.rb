module SSO
  class OpenidConnect < Base
    delegate :session, :to => :controller
    attr_reader :current_user

    def available?
      if session.present? && (session[:sso_method] == "SSO::OpenidConnect")
        session.delete(:sso_method) unless session[:user]
        return true
      end
      ((controller.api_request? && bearer_token_set?) || http_token.present?) && valid_issuer?
    end

    def authenticated?
      return false unless (payload = jwt_token.decode)
      return false unless (user = find_or_create_user_from_jwt(payload))

      @current_user = user
      update_session(payload)
      true
    end

    def authenticate!
      self.has_rendered = true
      controller.redirect_to login_url
    end

    def support_login?
      request.fullpath != controller.main_app.extlogin_users_path
    end

    def support_expiration?
      true
    end

    def expiration_url
      redirect_uri = "#{controller.main_app.extlogin_users_path}/redirect_uri"
      "#{redirect_uri}?logout=#{CGI.escape(request.base_url + controller.main_app.extlogin_users_path)}"
    end
    alias_method :login_url, :expiration_url

    def logout_url
      return Setting['login_delegation_logout_url'] if Setting['login_delegation_logout_url'].present?
      controller.extlogout_users_path
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
      logger = Foreman::Logging.logger('app')
      payload = jwt_token.decoded_payload
      if payload.nil?
        logger.error "Invalid JWT received, please check connectivity with the OpenID Provider"
        return false
      end
      unless payload.key?('iss') && (payload['iss'] == Setting['oidc_issuer'])
        logger.error "Invalid OIDC issuer received in JWT."
        logger.debug "Received invalid OIDC issuer '#{payload['iss']}'"
        return false
      end
      true
    rescue JWT::DecodeError => e
      Foreman::Logging.exception('Failed to decode JWT', e)
      false
    end

    def update_session(payload)
      session[:sso_method] = self.class.to_s
    end

    def find_or_create_user_from_jwt(payload)
      attrs = { login: payload['preferred_username'],
                mail: payload['email'],
                firstname: payload['given_name'],
                lastname: payload['family_name'],
              }
      attrs[:groups] = payload['groups'] if payload['groups'].present?
      User.find_or_create_external_user(
        attrs,
        Setting['authorize_login_delegation_auth_source_user_autocreate']
      )
    end
  end
end
