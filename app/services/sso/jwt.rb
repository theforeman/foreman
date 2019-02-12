module SSO
  class Jwt < Base
    attr_reader :current_user

    def available?
      controller.api_request? && bearer_token_set?
    end

    def authenticate!
      payload = jwt_token.decode || {}
      user_id = payload['user_id']
      user = User.unscoped.except_hidden.find_by(id: user_id) if user_id
      @current_user = user
      user&.login
    rescue JWT::DecodeError
      Rails.logger.error "JWT SSO: Failed to decode JWT."
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
  end
end
