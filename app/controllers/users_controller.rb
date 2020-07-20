class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::UsersMixin
  include Foreman::Controller::Parameters::User
  include Foreman::Controller::BruteforceProtection
  include Foreman::TelemetryHelper

  rescue_from ActionController::InvalidAuthenticityToken, with: :login_token_reload
  skip_before_action :require_mail, :only => [:edit, :update, :logout, :stop_impersonation]
  skip_before_action :require_login, :check_user_enabled, :authorize, :session_expiry, :update_activity_time, :set_taxonomy, :set_gettext_locale_db, :only => [:login, :logout, :extlogout]
  skip_before_action :authorize, :only => [:extlogin, :impersonate, :stop_impersonation]
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

      process_success((editing_self? && !current_user.allowed_to?({:controller => 'users', :action => 'index'})) ? { :success_redirect => hosts_path } : {})
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
      redirect_to hosts_path
    else
      info _("You are already impersonating, click the impersonation icon in the top bar before starting a new impersonation.")
      redirect_to users_path
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
        logger.warn("Failed login attempt from #{request.ip} with username '#{params[:login].try(:[], 'login')}'")
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
    redirect_to sso_logout_path || login_users_path
  end

  def extlogout
    render :extlogout, :layout => 'login'
  end

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
    redirect_to (uri || hosts_path)
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
        redirect_to hosts_path and return
      end
      redirect_back_or_to hosts_path
      nil
    end
  end

  def login_token_reload(exception)
    raise exception unless request.post? && action_name == 'login'
    inline_warning _("CSRF protection token expired, please log in again")
    redirect_to login_users_path
  end
end
