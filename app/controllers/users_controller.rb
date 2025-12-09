class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::UsersMixin
  include Foreman::Controller::Parameters::User
  include Foreman::Controller::BruteforceProtection
  include Foreman::TelemetryHelper

  rescue_from ActionController::InvalidAuthenticityToken, with: :login_token_reload
  skip_before_action :require_mail, :only => [:edit, :update, :logout, :stop_impersonation]
  skip_before_action :require_login, :check_user_enabled, :authorize, :session_expiry, :update_activity_time, :set_taxonomy, :set_gettext_locale_db,
    :only => [:login, :logout, :extlogout, :oidc_passthru, :oidc_callback, :oidc_failure]
  skip_before_action :authorize, :only => [:extlogin, :impersonate, :stop_impersonation]
  skip_before_action :verify_authenticity_token, :only => [:oidc_passthru, :oidc_callback, :oidc_failure]
  before_action      :require_admin, :only => :impersonate
  after_action       :update_activity_time, :only => :login
  before_action      :verify_active_session, :only => :login

  def index
    @users = User.authorized(:view_users).except_hidden.search_for(params[:search], :order => params[:order]).includes(:auth_source, :cached_usergroups).paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      process_success
    else
      process_error
    end
  end

  def edit
    editing_self?
    @user = find_resource(:edit_users)
    (MailNotification.authorized_as(@user, :view_mail_notifications).subscriptable - @user.mail_notifications).sort_by(&:name).each do |mail_notification|
      @user.user_mail_notifications.build(:mail_notification_id => mail_notification.id)
    end
  end

  def update
    editing_self?
    @user = find_resource(:edit_users)
    if @user.update(user_params)
      update_sub_hostgroups_owners

      process_success((editing_self? && !current_user.allowed_to?({:controller => 'users', :action => 'index'})) ? { :success_redirect => helpers.current_hosts_path } : { :success_redirect => users_path })
    else
      process_error
    end
  end

  def destroy
    @user = find_resource(:destroy_users)
    if @user == User.current
      warning_link = { text: _("Logout"), href: logout_users_url }
      warning _("You cannot delete this user while logged in as this user"), { :link => warning_link }
      redirect_back(fallback_location: users_path)
      return
    end

    if session[:impersonated_by] == @user.id
      warning _("You must stop impersonation before deleting a user that has active impersonation session.")
      redirect_back(fallback_location: users_path)
      return
    end

    if @user.destroy
      process_success
    else
      process_error
    end
  end

  def impersonate
    user = User.enabled.find_by_id(params[:id])
    if user.nil?
      warning _("User is disabled")
      redirect_to users_path
      return
    end
    if session[:impersonated_by].blank?
      session[:impersonated_by] = User.current.id
      User.impersonator = User.current
      session[:user] = user.id
      success _("You impersonated user %s, to cancel the session, click the impersonation icon in the top bar.") % user.name
      Audit.create :auditable_type => 'User', :auditable_id => user.id, :user_id => User.current.id, :action => 'impersonate', :audited_changes => {}
      logger.info "User #{User.current.name} impersonated #{user.name}"
      redirect_to helpers.current_hosts_path
    else
      info _("You are already impersonating, click the impersonation icon in the top bar before starting a new impersonation.")
      redirect_to users_path
    end
  end

  def invalidate_jwt_for_all_users
    user_ids = User.authorized(:edit_users).ids.uniq
    JwtSecret.where(user_id: user_ids).destroy_all
    process_success(
      :success_msg => _('Successfully invalidated registration tokens for all users.')
    )
  end

  def invalidate_jwt
    @user = find_resource(:edit_users)
    @user.jwt_secret&.destroy
    respond_to do |format|
      format.html do
        process_success(
          :success_msg => _('Successfully invalidated registration tokens for %s.') % @user.login
        )
      end
      format.json do
        render :json => {}, :status => :ok
      end
    end
  end

  def stop_impersonation
    if session[:impersonated_by].present?
      user = User.unscoped.find_by_id(session[:impersonated_by])
      session[:user] = user.id
      session[:impersonated_by] = nil
      User.impersonator = nil
      render :json => { :message => _("You now act as %s again.") % user.name, :type => :success }
    else
      render :json => { :message => _("No active impersonate session."), :type => :warning }
    end
  end

  # Called from the login form.
  # Stores the user id in the session and redirects required URL or default homepage
  def login
    User.current = nil

    if bruteforce_attempt?
      inline_error _("Too many tries, please try again in a few minutes.")
      log_bruteforce
      telemetry_increment_counter(:bruteforce_locked_ui_logins)
      render :layout => 'login', :status => :unauthorized
      return
    end

    if request.post?
      backup_session_content { reset_session }
      intercept = SSO::FormIntercept.new(self)
      if intercept.available? && intercept.authenticated?
        user = intercept.current_user
      else
        user = User.try_to_login(params[:login]['login'], params[:login]['password'])
      end
      if user.nil?
        # failed to authenticate, and/or to generate the account on the fly
        inline_error _("Incorrect username or password")
        logger.warn("Failed login attempt from #{request.remote_ip} with username '#{params[:login].try(:[], 'login')}'")
        count_login_failure
        telemetry_increment_counter(:failed_ui_logins)
        redirect_to login_users_path
      elsif user.disabled?
        inline_error _("User account is disabled, please contact your administrator")
        redirect_to login_users_path
      else
        # valid user
        # If any of the user attributes provided by external auth source are invalid then throw a flash message to user on successful login.
        warning _("Some imported user account details cannot be saved: %s") % user.errors.full_messages.to_sentence unless user.errors.empty?
        login_user(user)
      end
    else
      if params[:status] && params[:status] == "401"
        render :layout => 'login', :status => params[:status]
      else
        render :layout => 'login'
      end
    end
  end

  def extlogin
    if session[:user]
      session.delete('organization_id')
      session.delete('location_id')
      user = User.find_by_id(session[:user])
      login_user(user)
      user.post_successful_login
    end
  end

  # Called from the logout link
  # Clears the rails session and redirects to the login action
  def logout
    if request.get?
      require_login
      return
    end

    TopbarSweeper.expire_cache
    sso_logout_path = get_sso_method.try(:logout_url)
    logger.info("User '#{User.unscoped.find_by_id(session[:user]).try(:login) || session[:user]}' logged out")
    session[:user] = @user = User.current = nil
    if flash[:success] || flash[:info] || flash[:error]
      flash.keep
    else
      session.clear
      inline_success _("Logged out - See you soon")
    end
    redirect_to(sso_logout_path || login_users_path, allow_other_host: true)
  end

  def extlogout
    render :extlogout, :layout => 'login'
  end

  # ========== OIDC Authentication Methods ==========

  # GET/POST /users/auth/:provider
  # Initiates the OIDC authentication flow
  # This is handled by OmniAuth middleware, but we need this action as fallback
  def oidc_passthru
    unless AuthSourceOidc.any?
      render_oidc_error(
        :service_unavailable,
        "OIDC authentication is not available",
        "No OIDC authentication providers are configured. Please contact your administrator."
      )
      return
    end

    provider_name = params[:provider]
    auth_source = AuthSourceOidc.find_by_provider_name(provider_name)

    unless auth_source
      render_oidc_error(
        :not_found,
        "Unknown authentication provider",
        "The requested authentication provider '#{provider_name}' is not configured."
      )
      return
    end

    # If OmniAuth didn't intercept, something is wrong with the configuration
    render_oidc_error(
      :internal_server_error,
      "OIDC configuration error",
      "OIDC provider '#{auth_source.name}' is configured but not properly initialized. Please restart Foreman."
    )
  end

  # GET/POST /users/auth/:provider/callback
  # Handles the OIDC callback from the identity provider
  def oidc_callback
    auth_hash = request.env['omniauth.auth']

    unless auth_hash
      Rails.logger.error "OIDC: No auth hash present in callback"
      render_oidc_error(
        :unauthorized,
        "Authentication failed",
        "No authentication data received from identity provider"
      )
      return
    end

    provider_name = auth_hash.provider
    Rails.logger.info "OIDC: Processing authentication callback for provider: #{provider_name}"
    Rails.logger.debug "OIDC: Auth hash: #{auth_hash.inspect}" if Rails.env.development?

    auth_source = AuthSourceOidc.find_by_provider_name(provider_name)

    unless auth_source
      Rails.logger.error "OIDC: Unknown provider in callback: #{provider_name}"
      render_oidc_error(
        :unauthorized,
        "Authentication failed",
        "Unknown authentication provider"
      )
      return
    end

    unless validate_oidc_token(auth_hash, auth_source)
      render_oidc_error(
        :unauthorized,
        "Invalid authentication token",
        "Token validation failed"
      )
      return
    end

    user = User.from_omniauth(auth_hash, auth_source)

    if user
      Rails.logger.info "OIDC: Successfully authenticated user: #{user.login} via #{auth_source.name}"

      login_user(user)
    else
      Rails.logger.error "OIDC: User creation/lookup failed for provider #{auth_source.name}"
      render_oidc_error(
        :forbidden,
        "User not authorized",
        "Your account could not be provisioned or found. Please contact your administrator."
      )
    end
  rescue => e
    Foreman::Logging.exception("OIDC: Error during authentication", e)

    render_oidc_error(
      :internal_server_error,
      "Authentication error",
      "An error occurred during authentication. Please try again or contact your administrator."
    )
  end

  # GET/POST /users/auth/failure
  # Handles authentication failures from OmniAuth
  def oidc_failure
    error_message = params[:message]
    error_type = params[:strategy]

    Rails.logger.error "OIDC: Authentication failure - #{error_type}: #{error_message}"

    render_oidc_error(
      :unauthorized,
      "Authentication failed",
      error_message || "An error occurred during authentication"
    )
  end

  # ========== End OIDC Methods ==========

  def test_mail
    begin
      user = find_resource
      if (params.has_key?(:user_email) && params[:user_email].blank?) || user.mail.blank?
        render :json => {:message => _("Email address is missing")}, :status => :unprocessable_entity
        return
      end
      MailNotification[:tester].deliver(:user => user, :email => params[:user_email] || user.mail)
    rescue => e
      Foreman::Logging.exception("Unable to send email", e)
      render :json => {:message => _("Unable to send email, check server logs for more information")}, :status => :unprocessable_entity
      return
    end
    render :json => {:message => _("Email was sent successfully")}, :status => :ok
  end

  private

  def find_resource(permission = :view_users)
    editing_self? ? User.find(User.current.id) : User.authorized(permission).except_hidden.find(params[:id])
  end

  def login_user(user)
    logger.info("User '#{user.login}' logged in from '#{request.ip}'")
    session[:user]         = user.id
    uri                    = session.to_hash.with_indifferent_access[:original_uri]
    session[:original_uri] = nil
    store_default_taxonomy(user, 'organization') unless session.has_key?(:organization_id)
    store_default_taxonomy(user, 'location') unless session.has_key?(:location_id)
    TopbarSweeper.expire_cache
    telemetry_increment_counter(:successful_ui_logins)
    redirect_to (uri || helpers.current_hosts_path)
  end

  def parameter_filter_context
    Foreman::Controller::Parameters::User::Context.new(:ui, controller_name, params[:action], editing_self?)
  end

  def verify_active_session
    if !request.post? && params[:status].blank? && User.unscoped.enabled.exists?(session[:user].presence)
      warning _("You have already logged in")
      # Prevent a redirect loop in case the previous page was login page -
      # e.g when csrf token expired but user already logged in from another tab
      if request.headers["Referer"] == login_users_url
        redirect_to helpers.current_hosts_path and return
      end
      redirect_back_or_to helpers.current_hosts_path
      nil
    end
  end

  def login_token_reload(exception)
    raise exception unless request.post? && action_name == 'login'
    inline_warning _("CSRF protection token expired, please log in again")
    redirect_to login_users_path
  end

  # ========== OIDC Private Helpers ==========

  def validate_oidc_token(auth_hash, auth_source)
    # The omniauth-openid-connect gem already validates:
    # 1. Token signature using JWKS
    # 2. Token expiration (exp claim)
    # 3. Token not-before (nbf claim)
    # 4. Issuer (iss claim)
    # 5. Audience (aud claim) - matches client_id
    # 6. Nonce to prevent replay attacks

    # Additional validation
    id_token = auth_hash.credentials&.id_token

    unless id_token
      Rails.logger.error "OIDC: No ID token present"
      return false
    end

    unless auth_hash.uid.present?
      Rails.logger.error "OIDC: No subject (sub) claim in token"
      return false
    end

    token_issuer = auth_hash.extra&.raw_info&.iss || auth_hash.info&.issuer

    unless token_issuer == auth_source.oidc_issuer
      Rails.logger.error "OIDC: Issuer mismatch - expected #{auth_source.oidc_issuer}, got #{token_issuer}"
      return false
    end

    Rails.logger.info "OIDC: Token validation successful for #{auth_source.name}"
    true
  rescue => e
    Rails.logger.error "OIDC: Token validation error: #{e.message}"
    false
  end

  def render_oidc_error(status, title, message)
    @error_title = title
    @error_message = message

    respond_to do |format|
      format.html { render 'users/oidc_error', status: status, layout: 'login' }
      format.json { render json: { error: title, message: message }, status: status }
    end
  end
end
