class AuthSourceOidc < AuthSource
  CLIENT_AUTH_METHODS = {
    'client_secret_basic' => N_('HTTP Basic authentication'),
    'client_secret_post' => N_('Request body authentication'),
    'none' => N_('Public client'),
  }.freeze
  SUPPORTED_ALGORITHMS = %w[RS256 RS384 RS512 PS256 PS384 PS512 ES256 ES384 ES512].freeze

  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include Encryptable
  include Taxonomix
  include NormalizeCacert

  encrypts :oidc_client_secret

  has_many :oidc_identities, :dependent => :restrict_with_error, :foreign_key => :auth_source_id, :inverse_of => :auth_source
  has_many :linked_users, :through => :oidc_identities, :source => :user

  before_destroy EnsureNotUsedBy.new(:oidc_identities), :prepend => true

  validates :oidc_issuer, :oidc_client_id, :presence => true
  validates :oidc_issuer, :url_schema => ['https']
  validates :oidc_authorization_endpoint, :oidc_token_endpoint, :oidc_userinfo_endpoint,
    :oidc_jwks_uri, :oidc_end_session_endpoint, :url_schema => ['https'], :allow_blank => true
  validates :oidc_client_auth_method, :inclusion => { :in => CLIENT_AUTH_METHODS.keys }
  validates :oidc_scopes, :presence => true
  validates :oidc_allowed_algorithms, :presence => true
  validates :cacert, :cacert => true
  validates :oidc_login_claim, :oidc_email_claim, :oidc_firstname_claim,
    :oidc_lastname_claim, :oidc_groups_claim, :presence => true
  validate :openid_scope_present
  validate :issuer_identifier_valid
  validate :manual_endpoints_present, :unless => :oidc_use_discovery?
  validate :client_secret_present, :unless => :public_client?
  validate :pkce_required_for_public_client
  validate :supported_signing_algorithms
  validate :api_audience_present, :if => :oidc_allow_api_bearer?

  before_validation :clear_client_secret_for_public_client

  after_commit :expire_metadata_cache

  scope :enabled, -> { where(:oidc_enabled => true) }

  def auth_method_name
    'OIDC'
  end

  def metadata(force: false)
    Oidc::ProviderMetadata.new(self).fetch(:force => force)
  end

  def test_connection
    raise Oidc::ConfigurationError, errors.full_messages.to_sentence unless valid?

    provider_metadata = metadata(:force => true)
    Oidc::JwtVerifier.new(self).validate(:jwks_uri => provider_metadata.fetch('jwks_uri'), :force => true)
    { :success => true, :message => _('OpenID Connect provider validation was successful.') }
  rescue Oidc::Error => exception
    raise Foreman::WrappedException.new(exception, N_('Unable to validate the OpenID Connect provider'))
  end

  def scopes
    oidc_scopes.to_s.split(/\s+/).reject(&:blank?).uniq
  end

  def allowed_algorithms
    oidc_allowed_algorithms.to_s.split(/[\s,]+/).reject(&:blank?).uniq
  end

  def api_audiences
    oidc_api_audiences.to_s.split(/[\s,]+/).reject(&:blank?).uniq
  end

  def public_client?
    oidc_client_auth_method == 'none'
  end

  def supports_refresh?
    false
  end

  def sync_usergroups(user, external_names)
    return unless usergroup_sync?

    normalized_names = Array(external_names).filter_map do |name|
      name.to_s.downcase.presence
    end.uniq
    group_name = ExternalUsergroup.arel_table[:name].lower
    mapped_ids = external_usergroups.where(group_name.in(normalized_names)).pluck(:usergroup_id)
    current_ids = user.usergroups.where(:id => external_usergroups.select(:usergroup_id)).pluck(:id)

    User.as_anonymous_admin do
      UsergroupMember.transaction do
        user.usergroup_ids = (user.usergroup_ids - current_ids + mapped_ids).uniq
        user.save!(:validate => false)
      end
    end
  rescue ActiveRecord::ActiveRecordError => exception
    raise Oidc::AuthenticationError, N_('Unable to synchronize OpenID Connect user groups'), exception.backtrace
  end

  private

  def openid_scope_present
    errors.add(:oidc_scopes, N_('must include the openid scope')) unless scopes.include?('openid')
  end

  def manual_endpoints_present
    [:oidc_authorization_endpoint, :oidc_token_endpoint, :oidc_jwks_uri].each do |attribute|
      errors.add(attribute, :blank) if public_send(attribute).blank?
    end
  end

  def client_secret_present
    errors.add(:oidc_client_secret, :blank) if oidc_client_secret.blank?
  end

  def pkce_required_for_public_client
    errors.add(:oidc_use_pkce, N_('must be enabled for public clients')) if public_client? && !oidc_use_pkce?
  end

  def issuer_identifier_valid
    uri = URI.parse(oidc_issuer.to_s)
    return if uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil?

    errors.add(:oidc_issuer, N_('must be an HTTPS URL without credentials, query parameters, or a fragment'))
  rescue URI::InvalidURIError
    errors.add(:oidc_issuer, N_('is not a valid URL'))
  end

  def supported_signing_algorithms
    unsupported = allowed_algorithms - SUPPORTED_ALGORITHMS
    return if allowed_algorithms.present? && unsupported.empty?

    errors.add(:oidc_allowed_algorithms, N_('must contain only supported asymmetric signing algorithms'))
  end

  def clear_client_secret_for_public_client
    self.oidc_client_secret = nil if public_client?
  end

  def api_audience_present
    if api_audiences.empty?
      errors.add(:oidc_api_audiences, :blank)
    elsif api_audiences.include?(oidc_client_id)
      errors.add(:oidc_api_audiences, N_('must not include the browser client ID'))
    end
  end

  def expire_metadata_cache
    return unless id

    Rails.cache.delete(Oidc::ProviderMetadata.cache_key(id))
    Rails.cache.delete(Oidc::JwtVerifier.cache_key(id))
  end
end
