module SSO
  # Processes login via tokens set by apache mod_auth_openidc.
  # Compatible with:
  #  * keycloak providing a JWT as the id_token.
  #  * gitlab when mod_auth_openidc is configured with:
  #     OIDCPassIDTokenAs "payload" # Provides HTTP_OIDC_ID_TOKEN_PAYLOAD header variable.
  #     OIDCPassUserInfoAs "json" # Provides HTTP_OIDC_USERINFO_JSON header variable.
  # OIDC scope should include profile and email for foreman account creation e.g.
  #  OIDCScope "openid profile email"
  class OpenidConnect < Base
    delegate :session, :to => :controller
    attr_reader :current_user

    def available?
      if session.present? && (session[:sso_method] == "SSO::OpenidConnect")
        session.delete(:sso_method) unless session[:user]
        return true
      end
      ((controller.api_request? && bearer_token_set?) || http_oidc_access_token.present?) && valid_issuer?
    end

    def authenticated?
      return false unless (payload = id_token_payload)
      return false unless (user = find_or_create_user_from_payload(payload))

      logger = Foreman::Logging.logger('app')
      logger.debug "SSO OpenidConnect authenticated with payload: #{payload}"
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

    # Get the OIDC id_token json payload according to what was provided.
    def id_token_payload
      if http_oidc_id_token_payload.present?
        payload = JSON.parse(http_oidc_id_token_payload)
      else
        payload = jwt_token.decoded_payload
      end
      payload
    rescue JWT::DecodeError => e
      Foreman::Logging.exception('Failed to decode JWT', e)
      false
    end

    # OIDC id_token is a json payload when apache mod_auth_openidc has OIDCPassIDTokenAs "payload"
    def http_oidc_id_token_payload
      request.env['HTTP_OIDC_ID_TOKEN_PAYLOAD']
    end

    # OIDC userinfo available when apache mod_auth_openidc has OIDCPassUserInfoAs "json"
    # Useful to create the foreman account from OIDC providers who do not provide a JWT as the id_token.
    def http_oidc_userinfo_json
      request.env['HTTP_OIDC_USERINFO_JSON']
    end

    def jwt_token
      @jwt_token ||= jwt_token_from_request
    end

    def jwt_token_from_request
      token = (request.authorization.present? && request.authorization.split(' ')[1]) ||
        http_oidc_access_token
      OidcJwt.new(token)
    end

    def bearer_token_set?
      request.authorization.present? && request.authorization.start_with?('Bearer')
    end

    # Validate the configured issuer matches the OIDC payload issuer.
    def valid_issuer?
      logger = Foreman::Logging.logger('app')
      payload = id_token_payload
      if payload.nil?
        logger.error "Invalid payload received, please check connectivity with the OpenID Provider"
        return false
      end
      unless payload.key?('iss') && (payload['iss'] == Setting['oidc_issuer'])
        logger.error "Invalid OIDC issuer received in payload."
        logger.debug "Received invalid OIDC issuer '#{payload['iss']}'"
        return false
      end
      true
    end

    def update_session(payload)
      session[:sso_method] = self.class.to_s
    end

    def find_or_create_user_from_payload(payload)
      # Merge additional OIDC user info if available.
      if http_oidc_userinfo_json.present?
        userinfo = JSON.parse(http_oidc_userinfo_json)
        payload = payload.merge(userinfo)
      end
      logger = Foreman::Logging.logger('app')
      logger.debug "SSO OpenidConnect create user from payload: #{payload}"
      # Detect keycloak attrs, falling back to gitlab attrs.
      attr_login = payload.has_key?('preferred_username') ? payload['preferred_username'] : payload['nickname']
      attr_firstname = payload.has_key?('given_name') ? payload['given_name'] : payload['name']
      attr_lastname = payload.has_key?('family_name') ? payload['family_name'] : ''
      attrs = { login: attr_login,
                mail: payload['email'],
                firstname: attr_firstname,
                lastname: attr_lastname,
              }
      attrs[:groups] = payload['groups'] if payload['groups'].present?
      User.find_or_create_external_user(
        attrs,
        Setting['authorize_login_delegation_auth_source_user_autocreate']
      )
    end
  end
end
