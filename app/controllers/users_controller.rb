class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::UsersMixin
  include Foreman::Controller::Parameters::User

  skip_before_action :require_mail, :only => [:edit, :update, :logout]
  skip_before_action :require_login, :authorize, :session_expiry, :update_activity_time, :set_taxonomy, :set_gettext_locale_db, :only => [:login, :logout, :extlogout]
  skip_before_action :authorize, :only => :extlogin
  after_action       :update_activity_time, :only => :login
  before_action      :verify_active_session, :only => :login

  def index
    @users = User.authorized(:view_users).except_hidden.search_for(params[:search], :order => params[:order]).includes(:auth_source, :cached_usergroups).paginate(:page => params[:page])
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
    if !params[:no_modal] && editing_self? && request.xhr?
      render :layout => 'modal', :locals => {
        :id => 'edit-user-modal',
        :title => _("My Account"),
        :big => true,
        :buttons => [] }
    end
  end

  def update
    editing_self?
    @user = find_resource(:edit_users)
    if @user.update_attributes(user_params)
      update_sub_hostgroups_owners
      if request.xhr?
        render :nothing => true, :status => :ok
      else
        process_success((editing_self? && !current_user.allowed_to?({:controller => 'users', :action => 'index'})) ? { :success_redirect => hosts_path } : {})
      end
    else
      render :edit, :layout => false
    end
  end

  def destroy
    @user = find_resource(:destroy_users)
    if @user == User.current
      notice _("You cannot delete this user while logged in as this user.")
      redirect_to :back
      return
    end
    if @user.destroy
      process_success
    else
      process_error
    end
  end

  # Called from the login form.
  # Stores the user id in the session and redirects required URL or default homepage
  def login
    User.current = nil
    if request.post?
      backup_session_content { reset_session }
      intercept = SSO::FormIntercept.new(self)
      if intercept.available? && intercept.authenticated?
        user = intercept.current_user
      else
        user = User.try_to_login(params[:login]['login'], params[:login]['password'])
      end
      if user.nil?
        #failed to authenticate, and/or to generate the account on the fly
        error _("Incorrect username or password")
        redirect_to login_users_path
      else
        #valid user
        #If any of the user attributes provided by external auth source are invalid then throw a flash message to user on successful login.
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
    end
  end

  # Called from the logout link
  # Clears the rails session and redirects to the login action
  def logout
    if request.get?
      require_login
      return
    end

    TopbarSweeper.expire_cache(self)
    sso_logout_path = get_sso_method.try(:logout_url)
    session[:user] = @user = User.current = nil
    if flash[:notice] || flash[:error]
      flash.keep
    else
      session.clear
      notice _("Logged out - See you soon")
    end
    redirect_to sso_logout_path || login_users_path
  end

  def extlogout
    render :extlogout, :layout => 'login'
  end

  def test_mail
    begin
      user = find_resource(:edit_users)
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
    session[:user]         = user.id
    uri                    = session.to_hash.with_indifferent_access[:original_uri]
    session[:original_uri] = nil
    set_current_taxonomies(user, {:session => session})
    TopbarSweeper.expire_cache(self)
    redirect_to (uri || hosts_path)
  end

  def parameter_filter_context
    Foreman::Controller::Parameters::User::Context.new(:ui, controller_name, params[:action], editing_self?)
  end

  def verify_active_session
    if !request.post? && params[:status].blank? && User.unscoped.exists?(session[:user].presence)
      warning _("You have already logged in")
      redirect_back_or_to hosts_path
      return
    end
  end
end
