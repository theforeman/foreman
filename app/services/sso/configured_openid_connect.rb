module SSO
  class ConfiguredOpenidConnect < Base
    attr_reader :current_user

    def available?
      return false unless controller.api_request? && bearer_token.present?

      @auth_source = provider_for_token
      @auth_source.present?
    end

    def authenticated?
      payload = Oidc::AccessTokenVerifier.new(auth_source).verify(bearer_token)
      identity = auth_source.oidc_identities.find_by(:subject => payload['sub'])
      @current_user = User.unscoped.except_hidden.enabled.find_by(:id => identity&.user_id)
      @current_user.present?
    rescue Oidc::Error => exception
      Foreman::Logging.exception('Configured OpenID Connect bearer authentication failed', exception)
      false
    end

    private

    attr_reader :auth_source

    def provider_for_token
      payload = JWT.decode(bearer_token, nil, false).first
      issuer = payload['iss']
      audiences = payload['aud'].is_a?(Array) ? payload['aud'] : [payload['aud']]
      return unless issuer.is_a?(String) && audiences.present? && audiences.all? { |audience| audience.is_a?(String) }

      matches = AuthSourceOidc.enabled.where(:oidc_allow_api_bearer => true, :oidc_issuer => issuer).select do |auth_source|
        (auth_source.api_audiences & audiences).present?
      end
      matches.one? ? matches.first : nil
    rescue JWT::DecodeError
      nil
    end

    def bearer_token
      return @bearer_token if defined?(@bearer_token)

      scheme, token = request.authorization.to_s.split(/\s+/, 2)
      @bearer_token = scheme&.casecmp('Bearer')&.zero? ? token.presence : nil
    end
  end
end
