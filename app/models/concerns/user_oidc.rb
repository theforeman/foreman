# Concern for OIDC authentication support
module UserOidc
  extend ActiveSupport::Concern

  included do
    validates :oidc_subject, uniqueness: { scope: :oidc_issuer }, allow_nil: true
  end

  class_methods do
    # Find or create a user from OIDC authentication data
    # @param auth_hash [OmniAuth::AuthHash] The authentication hash from OmniAuth
    # @param auth_source [AuthSourceOidc] The OIDC auth source that authenticated this user
    # @return [User, nil] The user object or nil if creation fails
    def from_omniauth(auth_hash, auth_source = nil)
      # Get issuer from auth source (most reliable) or auth_hash
      issuer = auth_source&.oidc_issuer || auth_hash.extra&.raw_info&.iss || auth_hash.info&.issuer
      subject = auth_hash.uid
      email = auth_hash.info&.email
      name = auth_hash.info&.name

      Rails.logger.info "OIDC: Attempting to authenticate user with subject: #{subject}, issuer: #{issuer}"

      # FIRST: Try to find by subject and issuer - this is the most reliable lookup
      user = User.unscoped.find_by(oidc_subject: subject, oidc_issuer: issuer)
      if user
        Rails.logger.info "OIDC: Found existing user #{user.login} by OIDC subject"
        update_oidc_user(user, auth_hash)
        return user
      end

      Rails.logger.info "OIDC: No user found with subject #{subject}, checking other methods..."

      # Try to find by email if OIDC linking is enabled
      email_autolink = auth_source&.oidc_email_autolink
      if email_autolink && email.present?
        user = User.unscoped.find_by(mail: email)
        if user
          Rails.logger.info "OIDC: Linking existing user #{user.login} to OIDC identity"
          link_oidc_identity(user, subject, issuer, email, auth_source)
          return user
        end
      end

      # Create new user if auto-provisioning is enabled
      auto_provision = auth_source&.oidc_auto_provision
      if auto_provision
        Rails.logger.info "OIDC: Auto-provisioning new user"
        create_from_oidc(auth_hash, subject, issuer, email, name, auth_source)
      else
        Rails.logger.warn "OIDC: Auto-provisioning disabled, rejecting user"
        nil
      end
    end

    private

    def update_oidc_user(user, auth_hash)
      user.update(
        oidc_email: auth_hash.info&.email,
        last_login_on: Time.current
      )
    end

    def link_oidc_identity(user, subject, issuer, email, auth_source)
      attrs = {
        oidc_subject: subject,
        oidc_issuer: issuer,
        oidc_email: email,
        oidc_provider: auth_source&.provider_name || 'openid_connect',
      }
      attrs[:auth_source] = auth_source if auth_source
      user.update!(attrs)
    end

    def create_from_oidc(auth_hash, subject, issuer, email, name, auth_source)
      firstname, lastname = parse_name(name)
      login = generate_login(email, subject)

      groups_claim = auth_source&.oidc_groups_claim || 'groups'
      groups = extract_groups(auth_hash, groups_claim)

      # Create user with admin privileges to bypass authorization checks
      user = nil
      User.as_anonymous_admin do
        user = new(
          login: login,
          mail: email,
          firstname: firstname,
          lastname: lastname,
          oidc_subject: subject,
          oidc_issuer: issuer,
          oidc_email: email,
          oidc_provider: auth_source.provider_name,
          auth_source: auth_source,
          last_login_on: Time.current
        )

        if user.save
          Rails.logger.info "OIDC: Created new user #{user.login}"
          # Inherit locations and organizations from auth source
          user.locations = auth_source.locations
          user.organizations = auth_source.organizations
          assign_oidc_roles(user, groups, auth_source)
        else
          Rails.logger.error "OIDC: Failed to create user: #{user.errors.full_messages.join(', ')}"
          user = nil
        end
      end

      user
    end

    def parse_name(name)
      return ['', ''] if name.blank?
      parts = name.split(' ', 2)
      [parts[0] || '', parts[1] || '']
    end

    def generate_login(email, subject)
      if email.present?
        email.split('@').first
      else
        "oidc_#{subject}".gsub(/[^a-zA-Z0-9_-]/, '_')[0..99]
      end
    end

    def extract_groups(auth_hash, groups_claim)
      auth_hash.extra&.raw_info&.[](groups_claim) || []
    end

    def assign_oidc_roles(user, groups, auth_source)
      return unless groups.any?

      role_mappings = auth_source&.role_mappings_hash || {}

      groups.each do |group|
        role_names = role_mappings[group]
        next unless role_names

        Array(role_names).each do |role_name|
          role = Role.find_by(name: role_name)
          user.roles << role if role && !user.roles.include?(role)
        end
      end
    end
  end
end
