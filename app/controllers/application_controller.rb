require 'foreman/controller/auto_complete_search'

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  rescue_from ScopedSearch::QueryNotSupported, :with => :invalid_search_query
  rescue_from Exception, :with => :generic_exception
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # standard layout to all controllers
  helper 'layout'

  before_filter :require_ssl, :require_login
  before_filter :welcome, :detect_notices, :only => :index, :unless => :api_request?
  before_filter :authorize, :except => :login

  def welcome
    @searchbar = true
    klass = controller_name == "dashboard" ? "Host" : controller_name.camelize.singularize
    eval "#{klass}" rescue nil # We must force an autoload of the model class
    if eval "defined?(#{klass}) and #{klass}.respond_to?(:unconfigured?) and #{klass}.unconfigured?"
      @searchbar = false
      render :welcome rescue nil and return
    end
  rescue
    not_found
  end

  protected

  # Authorize the user for the requested action
  def authorize(ctrl = params[:controller], action = params[:action])
    return true if request.xhr?
    allowed = User.current.allowed_to?({:controller => ctrl.gsub(/::/, "_").underscore, :action => action})
    allowed ? true : deny_access
  end

  def deny_access
    User.current.logged? ? render_403 : require_login
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
  # Sets User.current to the logged in user, or to admin if logins are not used
  def require_login
    unless session[:user] and User.current = User.find(session[:user])
      # User is not found or first login
      if SETTINGS[:login] and SETTINGS[:login] == true
        # authentication is enabled
        if api_request?
          # JSON requests (REST API calls) use basic http authenitcation and should not use/store cookies
          user = authenticate_or_request_with_http_basic { |u, p| User.try_to_login(u, p) }
          User.current = user.is_a?(User) ? user : nil
          logger.warn("Failed authentication from #{request.remote_ip} #{user}") if User.current.nil?
          return !User.current.nil?
        end
        session[:original_uri] = request.fullpath # keep the old request uri that we can redirect later on
        redirect_to login_users_path and return
      else
        # We assume we always have a user logged in, if authentication is disabled, the user is the build-in admin account.
        unless User.current = User.find_by_login("admin")
          error "Unable to find internal system admin account - Recreating . . ."
          User.current = User.create_admin
        end
        session[:user] = User.current.id unless api_request?
      end
    end
  end

  # this method is returns the active user which gets used to populate the audits table
  def current_user
    User.current
  end

  def invalid_request
    render :text => 'Invalid query', :status => 400 and return
  end

  def not_found(exception = nil)
    logger.debug "not found: #{exception}" if exception
    respond_to do |format|
      format.html { render "common/404", :status => 404 }
      format.json { head :status => 404}
      format.yaml { head :status => 404}
      format.yml { head :status => 404}
    end
    return true
  end

  def api_request?
    request.format.json? or request.format.yaml?
  end

  # this method sets the Current user to be the Admin
  # its required for actions which are not authenticated by default
  # such as unattended notifications coming from an OS, or fact and reports creations
  def set_admin_user
    User.current = User.find_by_login("admin")
  end

  # searches for an object based on its name and assign it to an instance variable
  # required for models which implement the to_param method
  #
  # example:
  # @host = Host.find_by_name params[:id]
  def find_by_name
    not_found and return if (id = params[:id]).blank?

    obj = controller_name.singularize
    # determine if we are searching for a numerical id or plain name
    cond = "find_by_" + ((id =~ /^\d+$/ && id=id.to_i) ? "id" : "name")
    not_found and return unless eval("@#{obj} = #{obj.camelize}.#{cond}(id)")
  end

  def notice notice
    flash[:notice] = notice
  end

  def error error
    flash[:error] = error
  end

  def warning warning
    flash[:warning] = warning
  end

  # this method is used with nested resources, where obj_id is passed into the parameters hash.
  # it automatically updates the search text box with the relevant relationship
  # e.g. /hosts/fqdn/reports # would add host = fqdn to the search bar
  def setup_search_options
    params[:search] ||= ""
    params.keys.each do |param|
      if param =~ /(\w+)_id$/
        unless params[param].blank?
          query = "#{$1} = #{params[param]}"
          params[:search] += query unless params[:search].include? query
        end
      end
    end
  end

  private
  def detect_notices
    @notices = current_user.notices
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
      format.html { render :template => "common/403", :layout => !request.xhr?, :status => 403 }
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
      request.local? ? request.rescue_action_locally(exception) : rescue_action_in_public(exception)
    end
  end

  def process_success hash = {}
    hash[:object]                 ||= eval("@#{controller_name.singularize}")
    hash[:object_name]            ||= hash[:object].to_s
    hash[:success_msg]            ||= "Successfully #{action_name.pluralize.sub(/es$/,"ed").sub(/ys$/, "yed")} #{hash[:object_name]}."
    hash[:success_redirect]       ||= eval("#{controller_name}_url")
    hash[:json_code]                = :created if action_name == "create"

    respond_to do |format|
        format.html do
          notice hash[:success_msg]
          redirect_to hash[:success_redirect] and return
        end
        format.json { render :json => hash[:object], :status => hash[:json_code]}
    end
  end

  def process_error hash = {}
    hash[:object] ||= eval("@#{controller_name.singularize}")

    case action_name
    when "create" then hash[:render] ||= "new"
    when "update" then hash[:render] ||= "edit"
    else
      hash[:redirect] ||= eval("#{controller_name}_url")
    end
    hash[:error_msg] ||= hash[:object].errors[:base]

    hash[:json_code] ||= :unprocessable_entity
    logger.info "Failed to save: #{hash[:object].errors.full_messages.join(", ")}"
    respond_to do |format|
      format.html do
        if hash[:render]
          flash.now[:error] = hash[:error_msg].join("<br/>") unless hash[:error_msg].empty?
          render :action => hash[:render]
          return
        elsif hash[:redirect]
          error(hash[:error_msg].join("<br/>")) unless hash[:error_msg].empty?
          redirect_to hash[:redirect]
          return
        end
      end
      format.json { render :json => {"errors" => hash[:object].errors} , :status => hash[:json_code]}
    end
  end

  def redirect_back_or_to url
    redirect_to request.referer.empty? ? url : :back
  end

  def generic_exception(exception)
    return no_puppetclass_documentation_handler(exception) if exception.is_a?(ActionController::RoutingError)
    logger.warn "Operation FAILED: #{exception}"
    logger.debug Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
    render :template => "common/500", :layout => !request.xhr?, :status => 500, :locals => { :exception => exception}
  end

end
