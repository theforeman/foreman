class UsersController < ApplicationController

  filter_parameter_logging :password
  before_filter :require_login, :except => [:login, :logout]


  active_scaffold :users do |config|
    config.label = "Users"
    config.actions.exclude :create
    columns[:firstname].label = "First name"
    columns[:lastname].label = "Surname"
    columns[:admin].label = "Admin"
    config.columns = [:firstname, :lastname, :login, :mail, :admin, :auth_source, :last_login_on]
    config.columns[:auth_source].form_ui  = :select
    config.columns[:admin].form_ui  = :checkbox
    list.sorting = {:last_login_on => 'DESC' }
    config.update.columns.exclude :last_login_on
  end

  # Called from the login form.
  # Stores the username in the session and redirects required URL or default homepage
  def login
    session[:user] = nil
    if request.post?
      user = User.try_to_login(params[:login]['login'].downcase,  params[:login]['password'])
      if user.nil?
        #failed to authenticate, and/or to generate the account on the fly
        flash[:foreman_error] = "Incorrect username or password"
        redirect_to :action => :login
      else
        #valid user
        session[:user] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to (uri || {:controller => 'hosts'})
      end
    end
  end

  # Called from the logout link
  # Clears the rails session and redirects to the login action
  def logout
    session[:user] = @user = nil
    if flash[:foreman_notice] or flash[:foreman_error]
      flash.keep
    else
      flash[:foreman_notice] = "Logged out - See you soon"
    end
    redirect_to :action => "login"
  end

end
