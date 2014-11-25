class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::UsersMixin

  skip_before_filter :require_mail, :only => [:edit, :update, :logout]
  skip_before_filter :require_login, :authorize, :session_expiry, :update_activity_time, :set_taxonomy, :set_gettext_locale_db, :only => [:login, :logout, :extlogout]
  skip_before_filter :authorize, :only => :extlogin
  after_filter       :update_activity_time, :only => :login
  skip_before_filter :update_admin_flag, :only => :update

  def index
    @users = User.authorized(:view_users).except_hidden.search_for(params[:search], :order => params[:order]).includes(:auth_source, :cached_usergroups).paginate(:page => params[:page])
  end

  def new
    @user = User.new
  end

  def create
    if @user.save
      process_success
    else
      process_error
    end
  end

  def edit
    editing_self?
    @user = find_resource(:edit_users)
    (MailNotification.authorized_as(@user, :view_mail_notifications).subscriptable - @user.mail_notifications).each do |mail_notification|
      @user.user_mail_notifications.build(:mail_notification_id => mail_notification.id)
    end
  end

  def update
    editing_self?
    @user = find_resource(:edit_users)
    update_admin_flag
    if @user.update_attributes(user_params)
      update_sub_hostgroups_owners
      process_success((editing_self? && !current_user.allowed_to?({:controller => 'users', :action => 'index'})) ? { :success_redirect => hosts_path } : {})
    else
      process_error
    end
  end

  def destroy
    @user = find_resource(:destroy_users)
    if @user == User.current
      notice _("You cannot delete this user while logged in as this user.")
      redirect_to :back and return
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
    TopbarSweeper.expire_cache(self)
    sso_logout_path = get_sso_method.try(:logout_url)
    session[:user] = @user = User.current = nil
    if flash[:notice] or flash[:error]
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

  private

  def find_resource(permission = :view_users)
    editing_self? ? User.current : User.authorized(permission).except_hidden.find(params[:id])
  end

  def login_user(user)
    session[:user]         = user.id
    uri                    = session[:original_uri]
    session[:original_uri] = nil
    set_current_taxonomies(user, {:session => session})
    TopbarSweeper.expire_cache(self)
    redirect_to (uri || hosts_path)
  end
end
