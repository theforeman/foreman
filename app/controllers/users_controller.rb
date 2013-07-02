class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_user, :only => [:edit, :update, :destroy]
  skip_before_filter :require_mail, :only => [:edit, :update, :logout]
  skip_before_filter :require_login, :authorize, :session_expiry, :update_activity_time, :set_taxonomy, :set_gettext_locale_db, :only => [:login, :logout]
  after_filter       :update_activity_time, :only => :login

  attr_accessor :editing_self

  def index
    begin
      users = User.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      users = User.search_for('', :order => params[:order]).paginate :page => params[:page]
    end

    respond_to do |format|
      format.html do
        @users = users.paginate :page => params[:page], :include => [:auth_source]
      end
      format.json do
        render :json => users.all
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    admin = params[:user].delete :admin
    @user = User.new(params[:user]){|u| u.admin = admin }
    if @user.save
      @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
      process_success
    else
      process_error
    end
  end

  def edit
    if @user.user_facts.count == 0
      user_fact = @user.user_facts.build :operator => "==", :andor => "or"
      user_fact.fact_name_id = FactName.first.id if FactName.first
    end
  end

  def update
    # Remove keys for restricted variables when the user is editing their own account
    if editing_self
      for key in params[:user].keys
        params[:user].delete key unless %w{password_confirmation password mail firstname lastname locale}.include? key
      end
      User.current.editing_self = true
    end

    # Only an admin can update admin attribute of another user
    # this is required, as the admin field is blacklisted above
    admin = params[:user].delete :admin
    @user.admin = admin if User.current.admin

    if @user.update_attributes(params[:user])
      @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
      hostgroup_ids = params[:user]["hostgroup_ids"].reject(&:empty?).map(&:to_i) unless params[:user]["hostgroup_ids"].empty?
      update_hostgroups_owners(hostgroup_ids) unless hostgroup_ids.empty?
      process_success editing_self ? { :success_redirect => hosts_path } : {}
    else
      process_error
    end
    User.current.editing_self = false if editing_self

    # Remove locale from the session when set to "Browser Locale" and editing self
    session.delete(:locale) if params[:user][:locale].try(:empty?) and params[:id].to_i == User.current.id
  end

  def destroy
    if @user == User.current
      notice _("You are currently logged in, suicidal?")
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
    session[:user] = User.current = nil
    session[:locale] = nil
    if request.post?
      user = User.try_to_login(params[:login]['login'].downcase, params[:login]['password'])
      if user.nil?
        #failed to authenticate, and/or to generate the account on the fly
        error _("Incorrect username or password")
        redirect_to login_users_path
      else
        #valid user
        login_user(user)
      end
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

  private
  def authorize(ctrl = params[:controller], action = params[:action])
    # Editing self is true when the user is granted access to just their own account details

    if action == 'auto_complete_search' and User.current.allowed_to?({:controller => ctrl, :action => 'index'})
      return true
    end

    self.editing_self = false
    return true if User.current.allowed_to?({:controller => ctrl, :action => action})
    if (action =~ /edit|update/ and params[:id].to_i == User.current.id)
      return self.editing_self = true
    else
      deny_access and return
    end
  end

  def find_user
    @user = User.find(params[:id])
  end

  def update_hostgroups_owners(hostgroup_ids)
    subhostgroups = Hostgroup.where(:id => hostgroup_ids).map(&:subtree).flatten.reject { |hg| hg.users.include?(@user) }
    subhostgroups.each { |subhs| subhs.users << @user }
  end

  def login_user(user)
    session[:user]         = user.id
    uri                    = session[:original_uri]
    session[:original_uri] = nil
    redirect_to (uri || hosts_path)
  end

end
