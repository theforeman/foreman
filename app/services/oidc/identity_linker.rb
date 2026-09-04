module Oidc
  class IdentityLinker
    def initialize(auth_source, authentication, user)
      @auth_source = auth_source
      @authentication = authentication
      @user = user
    end

    def link
      identity = auth_source.oidc_identities.find_by(:subject => authentication.subject)
      if identity && identity.user_id != user.id
        raise Oidc::AuthenticationError, N_('This OpenID Connect identity is already linked to another account')
      end

      identity ||= auth_source.oidc_identities.find_or_initialize_by(:user => user)
      identity.assign_attributes(
        :subject => authentication.subject,
        :email => authentication.email,
        :email_verified => authentication.email_verified,
        :last_login_on => Time.now.utc
      )
      identity.save!
      identity
    rescue ActiveRecord::RecordInvalid => exception
      raise Oidc::AuthenticationError.new(
        N_('Unable to link the OpenID Connect identity: %s'), exception.record.errors.full_messages.to_sentence
      )
    rescue ActiveRecord::RecordNotUnique => exception
      raise Oidc::AuthenticationError, N_('The OpenID Connect identity or provider is already linked'), exception.backtrace if @retried

      @retried = true
      retry
    end

    private

    attr_reader :auth_source, :authentication, :user
  end
end
