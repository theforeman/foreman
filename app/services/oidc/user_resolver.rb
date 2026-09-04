module Oidc
  class UserResolver
    Result = Struct.new(:user, :identity, :created, :keyword_init => true)

    def initialize(auth_source, authentication)
      @auth_source = auth_source
      @authentication = authentication
      @claims = Oidc::ClaimReader.new(authentication.claims)
    end

    def resolve
      identity = auth_source.oidc_identities.find_by(:subject => authentication.subject)
      return update_identity(identity, identity_user(identity)) if identity

      User.as_anonymous_admin do
        User.transaction do
          user = linked_user
          created = user.nil?
          user ||= provision_user
          raise Oidc::AuthenticationError, N_('No Foreman account is linked to this identity') unless user

          identity = auth_source.oidc_identities.create!(
            :user => user,
            :subject => authentication.subject,
            :email => authentication.email,
            :email_verified => authentication.email_verified,
            :last_login_on => Time.now.utc
          )
          update_user(user) unless created
          Result.new(:user => user, :identity => identity, :created => created)
        end
      end
    rescue ActiveRecord::RecordInvalid => exception
      raise Oidc::AuthenticationError.new(
        N_('Unable to link the OpenID Connect identity: %s'), exception.record.errors.full_messages.to_sentence
      )
    rescue ActiveRecord::RecordNotUnique => exception
      identity = auth_source.oidc_identities.find_by(:subject => authentication.subject)
      return update_identity(identity, identity_user(identity)) if identity

      raise Oidc::AuthenticationError, N_('The OpenID Connect identity or provider is already linked'), exception.backtrace
    end

    private

    attr_reader :auth_source, :authentication, :claims

    def update_identity(identity, user)
      raise Oidc::AuthenticationError, N_('User account is disabled') if user.disabled?

      User.as_anonymous_admin do
        identity.update!(
          :email => authentication.email,
          :email_verified => authentication.email_verified,
          :last_login_on => Time.now.utc
        )
        update_user(user)
      end
      Result.new(:user => user, :identity => identity, :created => false)
    end

    def identity_user(identity)
      User.unscoped.except_hidden.find_by(:id => identity.user_id) ||
        raise(Oidc::AuthenticationError, N_('No Foreman account is linked to this identity'))
    end

    def linked_user
      return unless auth_source.oidc_link_verified_email? && authentication.email_verified && authentication.email.present?

      users = User.unscoped.except_hidden.where('LOWER(mail) = ?', authentication.email.downcase).limit(2).to_a
      if users.length > 1
        raise Oidc::AuthenticationError, N_('More than one Foreman account uses the verified email address')
      end
      user = users.first
      raise Oidc::AuthenticationError, N_('User account is disabled') if user&.disabled?

      user
    end

    def provision_user
      return unless auth_source.onthefly_register?

      user = User.new(user_attributes.merge(:auth_source => auth_source))
      user.locations = auth_source.locations
      user.organizations = auth_source.organizations
      user.save!
      user
    end

    def update_user(user)
      return unless auth_source.oidc_update_user_attributes?

      attributes = user_attributes.except(:login).select { |_key, value| value.present? }
      unless user.update(attributes)
        Rails.logger.warn "Unable to update OIDC user #{user.login}: #{user.errors.full_messages.to_sentence}"
      end
    end

    def user_attributes
      {
        :login => unique_login,
        :mail => authentication.email,
        :firstname => claim_string(auth_source.oidc_firstname_claim),
        :lastname => claim_string(auth_source.oidc_lastname_claim),
      }
    end

    def unique_login
      requested = claim_string(auth_source.oidc_login_claim).to_s.presence || authentication.email.to_s.split('@').first.presence
      requested ||= "oidc-#{Digest::SHA256.hexdigest(authentication.subject).first(12)}"
      requested = requested.gsub(/[^[:alnum:]_\-@.\\$#+]/, '-').first(100)
      requested = "oidc-#{Digest::SHA256.hexdigest(authentication.subject).first(12)}" unless requested.match?(/[[:alnum:]]/)
      return requested unless User.unscoped.where(:lower_login => requested.downcase).exists?

      suffix = "-#{Digest::SHA256.hexdigest("#{auth_source.id}:#{authentication.subject}").first(8)}"
      "#{requested.first(100 - suffix.length)}#{suffix}"
    end

    def claim_string(path)
      value = claims.read(path)
      value if value.is_a?(String)
    end
  end
end
