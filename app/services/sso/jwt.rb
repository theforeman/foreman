module SSO
  class Jwt < Base
    attr_reader :current_user

    def available?
      controller.api_request? && bearer_token_set? && no_issuer?
    end

    def authenticate!
      payload = jwt_token.decode || {}
      user_id = payload['user_id']

      unless valid_scope?(payload['scope'])
        Rails.logger.warn "JWT SSO: Invalid scope for '#{controller.controller_permission}' controller."
        return
      end

      user = User.unscoped.except_hidden.find_by(id: user_id) if user_id
      @current_user = user
      user&.login
    rescue JWT::ExpiredSignature
      Rails.logger.warn "JWT SSO: Expired JWT token."
      nil
    rescue JWT::DecodeError
      Rails.logger.warn "JWT SSO: Failed to decode JWT."
      nil
    end

    def authenticated?
      self.user = User.current.presence || authenticate!
    end

    private

    def jwt_token
      @jwt_token ||= jwt_token_from_request
    end

    def jwt_token_from_request
      token = request.authorization.split(' ')[1]
      JwtToken.new(token)
    end

    def bearer_token_set?
      request.authorization.present? && request.authorization.start_with?('Bearer')
    end

    def no_issuer?
      jwt_token.decoded_payload.present? && !jwt_token.decoded_payload.key?('iss')
    end

    def valid_scope?(scope)
      return true if scope.empty?
      required_scope = "#{controller.controller_permission}##{controller.action_name}"
      scope.split(' ').include? required_scope
    end
  end
end
