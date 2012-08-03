class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  skip_before_filter :require_login, :authorize, :session_expiry, :update_activity_time, :only => [:login, :logout]
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
    @user = User.new(params[:user]){|u| u.admin = params[:user][:admin] }
    if @user.save
      @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
      process_success
    else
      process_error
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.user_facts.count == 0
      user_fact = @user.user_facts.build :operator => "==", :andor => "or"
      user_fact.fact_name_id = FactName.first.id if FactName.first
    end
  end

  def update
    @user = User.find(params[:id])
    admin = params[:user].delete :admin
    # Remove keys for restricted variables when the user is editing their own account
    if editing_self
      for key in params[:user].keys
        params[:user].delete key unless %w{password_confirmation password mail firstname lastname}.include? key
      end
      User.current.editing_self = true
    end
    if @user.update_attributes(params[:user])
      # Only an admin can update admin attribute of another use
      # this is required, as the admin field is blacklisted above
      @user.update_attribute(:admin, admin) if User.current.admin
      @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
      process_success editing_self ? { :success_redirect => hosts_path } : {}
    else
      process_error
    end
    User.current.editing_self = false if editing_self
  end

  def destroy
    @user = User.find(params[:id])
    if @user == User.current
      notice "You are currently logged in, suicidal?"
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
    if request.post?
      user = User.try_to_login(params[:login]['login'].downcase,  params[:login]['password'])
      if user.nil?
        #failed to authenticate, and/or to generate the account on the fly
        error "Incorrect username or password"
        redirect_to login_users_path
      else
        #valid user
        session[:user] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to (uri || hosts_path)
      end
    end
  end
  # Called from the logout link
  # Clears the rails session and redirects to the login action
  def logout
    session[:user] = @user = User.current = nil
    if flash[:notice] or flash[:error]
      flash.keep
    else
      session.clear
      notice "Logged out - See you soon"
    end
    redirect_to login_users_path
  end

  def auth_source_selected
    render :update do |page|
      if params[:auth_source_id] and AuthSource.find(params[:auth_source_id]).can_set_password?
        page['#password'].show
      else
        page['#password'].hide
      end
    end
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

end
