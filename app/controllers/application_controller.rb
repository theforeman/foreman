# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  rescue_from ActionController::RoutingError, :with => :no_puppetclass_documentation_handler

  filter_parameter_logging :root_pass

  # standard layout to all controllers
  layout 'standard'
  helper 'layout'

  before_filter :require_ssl, :require_login
  before_filter :load_tabs, :manage_tabs, :unless => :request_json?
  before_filter :welcome, :detect_notices, :only => :index, :unless => :request_json?

  # host list AJAX methods
  # its located here, as it might be requested from the dashboard controller or via the hosts controller
  def fact_selected
    @fact_name_id = params[:search_fact_name_id].to_i
    @via    = params[:via]
    @values = FactValue.find(:all, :select => 'DISTINCT value', :conditions => {
      :fact_name_id => @fact_name_id }, :order => 'value ASC') if @fact_name_id > 0
    render :partial => 'common/fact_selected', :layout => false
  end

  def import_environments
    @changed = Environment.importClasses
    if @changed[:obsolete][:environments].size > 0 or @changed[:obsolete][:puppetclasses].size > 0 or
       @changed[:new][:environments].size > 0      or @changed[:new][:puppetclasses].size
       @grouping = 3
      render :partial => "common/puppetclasses_or_envs_changed", :layout => true
    else
      redirect_to :back
    end
  rescue Exception => e
    flash[:foreman_error] = e
    redirect_to :back
  end

  def obsolete_and_new
    if params[:commit] == "Cancel"
      redirect_to environments_path
    else
      if (errors = Environment.obsolete_and_new(params[:changed])).empty?
        flash[:foreman_notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
      else
        flash[:foreman_error]  = "Failed to update the environments and puppetclasses from the on-disk puppet installation<br/>" + errors
      end
      redirect_to :back
    end
  end

  protected

   def no_puppetclass_documentation_handler(exception)
    if exception.message =~ /No route matches "\/puppet\/rdoc\/([^\/]+)\/classes\/(.+?)\.html/
      render :template => "puppetclasses/no_route", :locals => {:environment => $1, :name => $2.gsub("/","::")}, :layout => false
    else
      if local_request?
        rescue_action_locally exception
      else
        rescue_action_in_public exception
      end
    end
  end

  def require_ssl
    # if SSL is not configured, don't bother forcing it.
    return true unless SETTINGS[:require_ssl]
    # don't force SSL on localhost
    return true if request.host=~/localhost|127.0.0.1/
    # finally - redirect
    redirect_to :protocol => 'https' and return if request.protocol != 'https' and not request.ssl?
  end


  # Force a user to login if authentication is enabled
  # Sets @user to the logged in user, or to admin if logins are not used
  def require_login
    unless session[:user] and @user = User.find(session[:user])
      # User is not found or first login
      if SETTINGS[:login] and SETTINGS[:login] == true
        # authentication is enabled
        if request_json?
          # JSON requests (REST API calls) use basic http authenitcation and should not use/store cookies
          @user = authenticate_or_request_with_http_basic { |u, p| User.try_to_login(u, p) }
          return !@user.nil?
        end
        session[:original_uri] = request.request_uri # keep the old request uri that we can redirect later on
        redirect_to login_users_path and return
      else
        # We assume we always have a user logged in, if authentication is disabled, the user is the build-in admin account.
        unless @user = User.find_by_login("admin")
          flash[:foreman_error] = "Unable to find internal system admin account - Recreating . . ."
          @user = User.create_admin
        end
        session[:user] = @user.id unless request_json?
      end
    end
  end

  def current_user
    @user
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

    return if params[:tab_name].empty? or params[:action] != "index"

    if    params[:tab_name] == "Reset"
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

end
