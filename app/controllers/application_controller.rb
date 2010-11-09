# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  rescue_from ActionController::RoutingError, :with => :no_puppetclass_documentation_handler

  # standard layout to all controllers
  layout 'standard'
  helper 'layout'

  before_filter :require_ssl, :require_login
  before_filter :load_tabs, :manage_tabs, :unless => :request_json?
  before_filter :welcome, :detect_notices, :only => :index, :unless => :request_json?
  before_filter :authorize, :except => :login

  # Authorize the user for the requested action
  def authorize(ctrl = params[:controller], action = params[:action])
    return true if request.xhr?
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action})
    allowed ? true : deny_access
  end

  def deny_access
    User.current.logged? ? render_403 : require_login
  end

  protected

  def require_ssl
    # if SSL is not configured, don't bother forcing it.
    return true unless SETTINGS[:require_ssl]
    # don't force SSL on localhost
    return true if request.host=~/localhost|127.0.0.1/
    # finally - redirect
    redirect_to :protocol => 'https' and return if request.protocol != 'https' and not request.ssl?
  end


  # Force a user to login if authentication is enabled
  # Sets User.current to the logged in user, or to admin if logins are not used
  def require_login
    unless session[:user] and User.current = User.find(session[:user])
      # User is not found or first login
      if SETTINGS[:login] and SETTINGS[:login] == true
        # authentication is enabled
        if request_json?
          # JSON requests (REST API calls) use basic http authenitcation and should not use/store cookies
          User.current = authenticate_or_request_with_http_basic { |u, p| User.try_to_login(u, p) }
          return !User.current.nil?
        end
        session[:original_uri] = request.request_uri # keep the old request uri that we can redirect later on
        redirect_to login_users_path and return
      else
        # We assume we always have a user logged in, if authentication is disabled, the user is the build-in admin account.
        unless User.current = User.find_by_login("admin")
          flash[:foreman_error] = "Unable to find internal system admin account - Recreating . . ."
          User.current = User.current = User.create_admin
        end
        session[:user] = User.current.id unless request_json?
      end
    end
  end

  def current_user
    User.current
  end

  def invalid_request
    render :text => 'Invalid query', :status => 400 and return
  end

  def not_found
    render :text => "404 Not Found\n", :status => 404
  end

  def setgraph chart, data, options = {}
    data[:labels].each {|l| chart.add_column *l }
    chart.add_rows data[:values]
    defaults = { :width => 400, :height => 240, :is3D => true,
      :backgroundColor => "#E6DFCF", :legendBackgroundColor => "#E6DFCF" }

    defaults.merge(options).each {|k,v| chart.send "#{k}=",v if chart.respond_to? k}
    return chart
  end

  def welcome
    klass = controller_name.camelize.singularize
    eval "#{klass}" rescue nil # We must force an autoload of the model class
    #logger.debug "defined?(#{klass}) is ->#{eval "defined?(#{klass})"}<-"
    render :welcome and return if eval "defined?(#{klass}) and #{klass}.respond_to?(:unconfigured?) and #{klass}.unconfigured?" rescue nil
    false
  end

  def request_json?
    request.format.json?
  end

  # this method sets the Current user to be the Admin
  # its required for actions which are not authenicated by default
  # such as unattended notifications coming from an OS, or fact and reports creations
  def set_admin_user
    User.current = User.find_by_login("admin")
  end

  private
  def detect_notices
    @notices = current_user.notices
  end

  def active_tab=(value); @active_tab = session[:controller_active_tabs][controller_name] = value; end

  def load_tabs
    controller_tabs        = session[:controller_tabs]               ||= {}
    @tabs                  = controller_tabs[controller_name]        ||= {}
    controller_active_tabs = session[:controller_active_tabs]        ||= {}
    @active_tab            = controller_active_tabs[controller_name] ||= ""
  end

  def manage_tabs
    # Clear the active tab if jumping between different controller's
    @controller_changed       = session[:last_controller] != controller_name
    session[:last_controller] = controller_name
    self.active_tab           = "" if @controller_changed

    return true if params[:tab_name].empty? or params[:action] != "index"

    if params[:tab_name] == "Reset"
      self.active_tab    = ""
    elsif params[:remove_me] and @tabs.has_key? params[:tab_name]
      @tabs.delete params[:tab_name]
      # If we delete the active tab then clear the active tab selection
      if @active_tab == params[:tab_name]
        self.active_tab    = ""
      else
        # And redirect back as we do  not want to perform the deleted tab's search
        redirect_to :back
      end
    else
      self.active_tab    = params[:tab_name]
      @tabs[@active_tab] = params[:search]
    end
  end

  def require_admin
    unless User.current.admin?
      render_403
      return false
    end
    true
  end

  def render_403
    respond_to do |format|
      format.html { render :template => "common/403", :layout => (request.xhr? ? false : 'standard'), :status => 403 }
      format.atom { head 403 }
      format.yaml { head 403 }
      format.yml  { head 403 }
      format.xml  { head 403 }
      format.json { head 403 }
    end
    return false
  end

  # this has to be in the application controller, as the new request (for puppetdoc) url is not controller specific.
  def no_puppetclass_documentation_handler(exception)
    if exception.message =~ /No route matches "\/puppet\/rdoc\/([^\/]+)\/classes\/(.+?)\.html/
      render :template => "puppetclasses/no_route", :locals => {:environment => $1, :name => $2.gsub("/","::")}, :layout => false
    else
      local_request? ? rescue_action_locally(exception) : rescue_action_in_public(exception)
    end
  end

end
