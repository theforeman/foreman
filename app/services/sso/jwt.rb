require 'jwt'

module SSO
  class Jwt < Base
    def available?
      controller.api_request? && http_auth_set?
    end

    def authenticate!
      token = request.env["HTTP_AUTHORIZATION"].split(' ')
      @jwt = JWT.decode(token[1], nil, false)
      User.find_or_create_external_user({ login: @jwt.first["preferred_username"],
                                          mail: @jwt.first["email"],
                                          firstname: @jwt.first["given_name"],
                                          lastname: @jwt.first["family_name"]
                                        }, Setting['authorize_login_delegation_auth_source_user_autocreate'])
    rescue JWT::DecodeError
    end

    def authenticated?
      User.current.present? ? User.current.login : authenticate!
    end

    def http_auth_set?
      request.authorization.present? && request.authorization.start_with?('Bearer')
    end

    def current_user
      User.unscoped.except_hidden.find_by_login(@jwt.first["preferred_username"])
    end
  end
end
