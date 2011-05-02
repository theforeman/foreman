class UsersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  filter_parameter_logging :password, :password_confirmation
  skip_before_filter :require_login, :only => [:login, :logout]
  skip_before_filter :authorize, :only => [:login, :logout]

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
    @user = User.new(params[:user])
    @user.admin = params[:admin]
    if @user.save
      @user.roles = Role.name_is("Anonymous")
      process_success
    else
      process_error
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.user_facts.count == 0
      user_fact = @user.user_facts.build :operator => "==", :andor => "or"
      user_fact.fact_name_id = Puppet::Rails::FactName.first.id if Puppet::Rails::FactName.first
      true
    end
  end

  def update
    @user = User.find(params[:id])
    admin = params[:user].delete :admin
    # Remove keys for restricted variables when the user is granted minimal access only to their own account
    if @minimal_edit
      for key in params[:user].keys
        params[:user].delete key unless %w{password_confirmation password mail firstname lastname}.include? key
      end
    end
    if @user.update_attributes(params[:user])
      # Only an admin can update admin attribute of another use
      # this is required, as the admin field is blacklisted above
      @user.update_attribute(:admin, admin) if User.current.admin
      @user.roles << Role.find_by_name("Anonymous") unless @user.roles.map(&:name).include? "Anonymous"
      process_success
    else
      process_error
    end
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
        page.show 'password'
      else
        page.hide 'password'
      end
    end
  end

  private

  def authorize(ctrl = params[:controller], action = params[:action])
    # Minimal edit is true when the user is granted access to just their
    # own account details
    @minimal_edit = false
    return true if User.current.allowed_to?({:controller => ctrl, :action => action})
    if action =~ /edit|update/ and params[:id] == User.current.id.to_s
      return @minimal_edit=true
    else
      deny_access and return
    end
  end

end
