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
  before_filter :load_tabs, :manage_tabs
  before_filter :welcome, :only => :index

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


  #Force a user to login if ldap authentication is enabled
  def require_login
    return true unless SETTINGS[:login]
    unless session[:user] and @username = User.find(session[:user])
      session[:original_uri] = request.request_uri
      redirect_to login_users_path
    end
  end

  # returns current user
  def current_user
    @username
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

  private
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
