module SSO
  class Jwt < Base
    attr_reader :current_user, :scope

    def available?
      controller.api_request? && bearer_token_set? && no_issuer?
    end

    def authenticate!
      payload = jwt_token.decode || {}
      user_id = payload['user_id']
      user = User.unscoped.except_hidden.find_by(id: user_id) if user_id

      @current_user = user
      @scope = payload['scope'] || []

      user&.login
    rescue JWT::ExpiredSignature
      Rails.logger.error "JWT SSO: Expired JWT token."
      nil
    rescue JWT::DecodeError
      Rails.logger.error "JWT SSO: Failed to decode JWT."
      nil
    end

    def authenticated?
      self.user = User.current.presence || authenticate!
    end

    def allowed_to?(action)
      return false if @current_user.disabled?
      return true if @current_user.admin?

      required_permissions = Foreman::AccessControl.permissions_for_controller_action(action).map(&:name)
      required_permissions.each do |permission|
        return false unless @scope.include? permission.to_s
      end

      true
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
  end
end
