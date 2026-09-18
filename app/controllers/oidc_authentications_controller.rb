class OidcAuthenticationsController < ApplicationController
  include Foreman::TelemetryHelper

  FLOW_TTL = Oidc::AuthorizationRequest::STATE_TTL
  MAX_CONCURRENT_FLOWS = 5

  skip_before_action :require_login, :check_user_enabled, :authorize, :session_expiry,
    :update_activity_time, :set_taxonomy, :require_mail, :check_empty_taxonomy,
    :set_gettext_locale_db, :only => [:start, :callback]
  after_action :update_activity_time, :only => :callback

  def start
    if (user = User.unscoped.enabled.find_by(:id => session[:user]))
      inline_warning _('You are already logged in. Use account linking to connect another provider.')
      redirect_to edit_user_path(:id => user)
      return
    end
    session.delete(:user)

    auth_source = find_oidc_auth_source
    authorization = Oidc::AuthorizationRequest.new(auth_source, callback_url)
    remember_flow(authorization.session_data)
    redirect_to authorization.url, :allow_other_host => true
  rescue ActiveRecord::RecordNotFound
    authentication_failed(_('The selected OpenID Connect provider is not available'))
  rescue Oidc::Error => exception
    authentication_failed(exception.message, exception)
  end

  def link
    auth_source = find_oidc_auth_source
    authorization = Oidc::AuthorizationRequest.new(auth_source, callback_url)
    flow = authorization.session_data.merge('link_user_id' => User.current.id)
    remember_flow(flow)
    redirect_to authorization.url, :allow_other_host => true
  rescue ActiveRecord::RecordNotFound
    authentication_failed(_('The selected OpenID Connect provider is not available'))
  rescue Oidc::Error => exception
    authentication_failed(exception.message, exception)
  end

  def callback
    flow = consume_flow(params[:state])
    validate_flow(flow)
    raise Oidc::AuthenticationError, provider_error if params[:error].present?

    auth_source = AuthSourceOidc.enabled.find(flow.fetch('auth_source_id'))
    validate_linking_session(flow)
    authentication = Oidc::Authenticator.new(auth_source, callback_url).authenticate(
      params.require(:code), flow.fetch('nonce'), flow['code_verifier']
    )
    if flow['link_user_id']
      link_identity(auth_source, authentication, flow['link_user_id'])
      return
    end

    result = Oidc::UserResolver.new(auth_source, authentication).resolve
    raise Oidc::AuthenticationError, _('User account is disabled') if result.user.disabled?

    auth_source.sync_usergroups(result.user, authentication.groups)
    complete_login(result.user, auth_source)
  rescue ActionController::ParameterMissing, KeyError, ActiveRecord::RecordNotFound => exception
    authentication_failed(_('The OpenID Connect authentication response is incomplete'), exception)
  rescue Oidc::Error => exception
    authentication_failed(exception.message, exception)
  end

  private

  def callback_url
    foreman_url(callback_oidc_authentications_path)
  end

  def find_oidc_auth_source
    resource_finder(AuthSourceOidc.enabled, params[:id])
  end

  def foreman_url(path)
    "#{Setting[:foreman_url].to_s.delete_suffix('/')}#{path}"
  end

  def remember_flow(flow)
    flows = active_flows
    flows[flow.fetch('state')] = flow
    session[:oidc_authentications] = flows.sort_by { |_state, data| data.fetch('created_at') }.last(MAX_CONCURRENT_FLOWS).to_h
  end

  def consume_flow(state)
    flows = active_flows
    flow = flows.delete(state.to_s)
    session[:oidc_authentications] = flows
    flow
  end

  def active_flows
    cutoff = FLOW_TTL.ago.to_i
    session.to_hash.fetch('oidc_authentications', {}).select do |_state, flow|
      flow.is_a?(Hash) && flow['created_at'].to_i >= cutoff
    end
  end

  def validate_flow(flow)
    raise Oidc::AuthenticationError, _('The OpenID Connect authentication state is invalid or expired') unless flow
  end

  def provider_error
    _('The OpenID Connect provider rejected the authentication request (%s)') % params[:error].to_s.first(100)
  end

  def complete_login(user, auth_source)
    original_uri = session[:original_uri]
    backup_session_content([:organization_id, :location_id]) { reset_session }
    session[:user] = user.id
    session[:oidc_auth_source_id] = auth_source.id
    store_default_taxonomy(user, 'organization') unless session.has_key?(:organization_id)
    store_default_taxonomy(user, 'location') unless session.has_key?(:location_id)
    user.post_successful_login
    TopbarSweeper.expire_cache
    telemetry_increment_counter(:successful_ui_logins)
    Audit.manual_event!(
      :action => 'login',
      :auditable_type => 'User',
      :auditable_id => user.id,
      :auditable_name => user.to_label,
      :actor => user,
      :attribute => 'authentication',
      :value => "User '#{user.login}' logged in with OIDC provider '#{auth_source.name}'",
      :remote_address => request.remote_ip,
      :request_uuid => request.uuid
    )
    logger.info "User '#{user.login}' logged in with OIDC provider '#{auth_source.name}' from '#{request.ip}'"
    redirect_to(original_uri.presence || helpers.current_hosts_path)
  end

  def validate_linking_session(flow)
    return unless flow['link_user_id']

    user = User.unscoped.enabled.find_by(:id => session[:user])
    if user&.id == flow['link_user_id'].to_i
      User.current = user
      return
    end

    raise Oidc::AuthenticationError, _('The account linking session is no longer valid')
  end

  def link_identity(auth_source, authentication, user_id)
    user = User.unscoped.enabled.find(user_id)
    Oidc::IdentityLinker.new(auth_source, authentication, user).link
    auth_source.sync_usergroups(user, authentication.groups)
    Audit.manual_event!(
      :action => 'link',
      :auditable_type => 'User',
      :auditable_id => user.id,
      :auditable_name => user.to_label,
      :actor => user,
      :attribute => 'authentication',
      :value => "User '#{user.login}' linked OIDC provider '#{auth_source.name}'",
      :remote_address => request.remote_ip,
      :request_uuid => request.uuid
    )
    inline_success _('OpenID Connect identity linked successfully')
    redirect_to edit_user_path(:id => user)
  end

  def authentication_failed(message, exception = nil)
    Foreman::Logging.exception('OpenID Connect authentication failed', exception) if exception
    linking_user = User.unscoped.enabled.find_by(:id => session[:user])
    telemetry_increment_counter(:failed_ui_logins) unless linking_user
    Audit.manual_event!(
      :action => linking_user ? 'failed_link' : 'failed_login',
      :auditable_type => 'User',
      :auditable_id => linking_user&.id,
      :auditable_name => linking_user&.to_label,
      :actor => linking_user,
      :attribute => 'authentication',
      :value => linking_user ? 'OpenID Connect identity linking failed' : 'OpenID Connect login failed',
      :remote_address => request.remote_ip,
      :request_uuid => request.uuid
    )
    inline_error message
    redirect_to(linking_user ? edit_user_path(:id => linking_user) : login_users_path)
  end
end
