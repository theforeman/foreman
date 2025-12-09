# OpenID Connect Authentication Source
# Allows configuration of multiple OIDC identity providers
class AuthSourceOidc < AuthSource
  include Encryptable
  include Taxonomix

  encrypts :oidc_client_secret

  validates :oidc_issuer, presence: true, uniqueness: true
  validates :oidc_client_id, presence: true
  validates :oidc_client_secret, presence: true, on: :create
  validates :oidc_scopes, presence: true
  validate :validate_oidc_issuer_url

  scoped_search on: :oidc_issuer, complete_value: true

  after_initialize :set_defaults, if: :new_record?
  after_create :generate_redirect_uri

  # Update all OIDC redirect URIs when foreman_url changes
  def self.update_all_redirect_uris
    foreman_url = Setting[:foreman_url]
    return if foreman_url.blank?

    find_each do |auth_source|
      new_uri = "#{foreman_url.chomp('/')}/users/auth/#{auth_source.provider_name}/callback"
      auth_source.update_column(:oidc_redirect_uri, new_uri)
      Rails.logger.info "OIDC: Updated redirect_uri for '#{auth_source.name}': #{new_uri}"
    end
  end

  def authenticate(login, password)
    # OIDC doesn't use password authentication
    # Authentication is handled via OmniAuth callbacks
    nil
  end

  def auth_method_name
    "OIDC"
  end

  alias_method :to_label, :auth_method_name

  # assumes every user is valid as authentication is handled by the OIDC provider
  def valid_user?(name)
    name.present?
  end

  def supports_refresh?
    false
  end

  def provider_name
    "oidc_#{id}"
  end

  def self.find_by_provider_name(provider_name)
    return nil if provider_name.blank?
    id = provider_name.delete_prefix('oidc_')
    find_by(id: id)
  end

  def scopes_array
    (oidc_scopes || 'openid email profile').split(/[\s,]+/).map(&:to_sym)
  end

  def role_mappings_hash
    return {} if oidc_role_mappings.blank?
    YAML.safe_load(oidc_role_mappings, permitted_classes: [Symbol]) rescue {}
  end

  def role_mappings_hash=(mappings)
    self.oidc_role_mappings = mappings.to_yaml
  end

  def uses_manual_endpoints?
    oidc_authorization_endpoint.present? &&
      oidc_token_endpoint.present? &&
      oidc_jwks_uri.present?
  end

  def issuer_uri
    @issuer_uri ||= URI.parse(oidc_issuer) if oidc_issuer.present?
  end

  def redirect_uri
    oidc_redirect_uri
  end

  def login_url
    "/users/auth/#{provider_name}"
  end

  private

  def set_defaults
    self.oidc_scopes ||= 'openid email profile'
    self.oidc_groups_claim ||= 'groups'
    self.oidc_auto_provision ||= false
    self.oidc_email_autolink ||= false
  end

  def generate_redirect_uri
    foreman_url = Setting[:foreman_url]
    if foreman_url.blank?
      logger.warn "OIDC: Setting[:foreman_url] is not configured. Configure the setting to generate the redirect URI."
      return
    end

    callback_path = "/users/auth/#{provider_name}/callback"
    self.oidc_redirect_uri = "#{foreman_url.chomp('/')}#{callback_path}"

    update_column(:oidc_redirect_uri, oidc_redirect_uri)
    logger.info "OIDC: Generated redirect_uri for '#{name}': #{oidc_redirect_uri}"
  end

  def validate_oidc_issuer_url
    return if oidc_issuer.blank?

    begin
      uri = URI.parse(oidc_issuer)

      if uri.scheme.blank?
        errors.add(:oidc_issuer, "must be a valid URL with https:// scheme (e.g., https://accounts.google.com)")
        return
      end

      unless uri.scheme == 'https'
        errors.add(:oidc_issuer, "must use https:// scheme for security (got #{uri.scheme}://)")
        return
      end

      if uri.host.blank?
        errors.add(:oidc_issuer, "must include a valid hostname")
        nil
      end
    rescue URI::InvalidURIError => e
      errors.add(:oidc_issuer, "is not a valid URL: #{e.message}")
    end
  end
end
