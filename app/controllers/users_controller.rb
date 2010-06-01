class UsersController < ApplicationController

  filter_parameter_logging :password
  before_filter :require_login, :except => [:login, :logout]

  def index
    # set defaults search order - cant use default scope due to bug in AR
    # http://github.com/binarylogic/searchlogic/issues#issue/17
    params[:search] ||=  {}
    params[:search][:order] ||= "descend_by_firstname"

    @search = User.search(params[:search])
    @users = @search.paginate(:page => params[:page], :include => [:auth_source], :per_page => 15, :order => "firstname")
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:foreman_notice] = "Successfully created user."
      redirect_to users_url
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:foreman_notice] = "Successfully updated user."
      redirect_to users_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:foreman_notice] = "Successfully destroyed user."
    else
      flash[:foreman_error] = @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  def login
    session[:user] = nil
    if request.post?
      user = User.try_to_login(params[:login]['login'].downcase,  params[:login]['password'])
      if user.nil?
        #failed to authenticate, and/or to generate the account on the fly
        flash[:foreman_error] = "Incorrect username or password"
        redirect_to login_users_path
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
    redirect_to login_users_path
  end

end
