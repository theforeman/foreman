class ApplicationController < ActionController::Base
  include Foreman::Controller::Authentication
  include Foreman::ThreadSession::Cleaner

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  rescue_from ScopedSearch::QueryNotSupported, :with => :invalid_search_query
  rescue_from Exception, :with => :generic_exception if Rails.env.production?
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActionView::MissingTemplate, :with => :api_deprecation_error

  # standard layout to all controllers
  helper 'layout'

  before_filter :require_ssl, :require_login
  before_filter :set_gettext_locale_db, :set_gettext_locale
  before_filter :session_expiry, :update_activity_time, :unless => proc {|c| c.remote_user_provided? || c.api_request? } if SETTINGS[:login]
  before_filter :set_taxonomy, :require_mail, :check_empty_taxonomy
  before_filter :welcome, :only => :index, :unless => :api_request?
  before_filter :authorize

  cache_sweeper :topbar_sweeper

  def welcome
    @searchbar = true
    klass = controller_name == "dashboard" ? "Host" : controller_name.camelize.singularize
    if (klass.constantize.first.nil? rescue false)
      @searchbar = false
      render :welcome rescue nil and return
    end
  rescue
    not_found
  end

  def api_request?
    request.format.json? or request.format.yaml?
  end

  protected

  # Authorize the user for the requested action
  def authorize
    (render :json => { :error => "Authentication error" }, :status => :unauthorized and return) unless User.current.present?
    authorized ? true : deny_access
  end

  def deny_access
    (User.current.logged? || request.xhr?) ? render_403 : require_login
  end

  def require_ssl
    # if SSL is not configured, don't bother forcing it.
    return true unless SETTINGS[:require_ssl]
    # don't force SSL on localhost
    return true if request.host=~/localhost|127.0.0.1/
    # finally - redirect
    redirect_to :protocol => 'https' and return if request.protocol != 'https' and not request.ssl?
  end

  # This filter is called before FastGettext set_gettext_locale and sets user-defined locale
  # from db. It must be called after require_login.
  def set_gettext_locale_db
    params[:locale] ||= User.current.try(:locale)
  end

  def require_mail
    if User.current && User.current.mail.blank?
      notice _("Mail is Required")
      redirect_to edit_user_path(:id => User.current)
    end
  end

  # this method is returns the active user which gets used to populate the audits table
  def current_user
    User.current
  end

  def invalid_request
    render :text => _('Invalid query'), :status => 400
  end

  def not_found(exception = nil)
    logger.debug "not found: #{exception}" if exception
    respond_to do |format|
      format.html { render "common/404", :status => 404 }
      format.json { head :status => 404}
      format.yaml { head :status => 404}
      format.yml { head :status => 404}
    end
    true
  end

  def api_deprecation_error(exception = nil)
    if request.format.json? && !request.env['REQUEST_URI'].match(/\/api\//i)
      logger.error "#{exception.message} (#{exception.class})\n#{exception.backtrace.join("\n")}"
      msg = "/api/ prefix must now be used to access API URLs, e.g. #{request.env['HTTP_HOST']}/api#{request.env['REQUEST_URI']}"
      logger.error "DEPRECATION: #{msg}."
      render :json => {:message => msg}, :status => 400
    else
      raise exception
    end

  end

  # this method sets the Current user to be the Admin
  # its required for actions which are not authenticated by default
  # such as unattended notifications coming from an OS, or fact and reports creations
  def set_admin_user
    User.current = User.admin
  end

  def model_of_controller
    controller_path.singularize.camelize.gsub('/','::').constantize
  end


  # searches for an object based on its name and assign it to an instance variable
  # required for models which implement the to_param method
  #
  # example:
  # @host = Host.find_by_name params[:id]
  def find_by_name
    not_found and return if params[:id].blank?

    name = controller_name.singularize
    model = model_of_controller
    # determine if we are searching for a numerical id or plain name
    cond = "find" + (params[:id] =~ /\A\d+(-.+)?\Z/ ? "" : "_by_name")
    not_found and return unless instance_variable_set("@#{name}", model.send(cond, params[:id]))
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

  def session_expiry
    if session[:expires_at].blank? or (session[:expires_at].utc - Time.now.utc).to_i < 0
      expire_session
      session[:original_uri] = request.fullpath # keep the old request uri that we can redirect later on
    end
  rescue => e
    logger.warn "failed to determine if user sessions needs to be expired, expiring anyway: #{e}"
    expire_session
  end

  def update_activity_time
    session[:expires_at] = Setting[:idle_timeout].minutes.from_now.utc
  end

  def expire_session
    logger.info "Session for #{current_user} is expired."
    sso = get_sso_method
    reset_session
    if sso.nil? || !sso.support_expiration?
      flash[:warning] = _("Your session has expired, please login again")
      redirect_to login_users_path
    else
      redirect_to sso.expiration_url
    end
  end

  # returns current SSO method object according to session
  # nil is returned if nothing was found or invalid method is stored
  def get_sso_method
    if (sso_method_class = session[:sso_method])
      sso_method_class.constantize.new(self)
    end
  rescue NameError
    logger.error "Unknown SSO method #{sso_method_class}"
    nil
  end

  def ajax?
    request.xhr?
  end

  def ajax_request
    return head(:method_not_allowed) unless ajax?
  end

  def remote_user_provided?
    return false unless Setting["authorize_login_delegation"]
    return false if api_request? and not Setting["authorize_login_delegation_api"]
    (@remote_user = request.env["REMOTE_USER"]).present?
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
    false
  end

  # this is only used in hosts_controller (by SmartProxyAuth module) to render 403's
  def render_error(msg, status)
    render_403
  end

  def process_success hash = {}
    hash[:object]                 ||= instance_variable_get("@#{controller_name.singularize}")
    hash[:object_name]            ||= hash[:object].to_s
    unless hash[:success_msg]
      hash[:success_msg] = case action_name
                           when "create"
                             _("Successfully created %s.") % hash[:object_name]
                           when "update"
                             _("Successfully updated %s.") % hash[:object_name]
                           when "destroy"
                             _("Successfully deleted %s.") % hash[:object_name]
                           else
                             raise Foreman::Exception.new(N_("Unknown action name for success message: %s"), action_name)
                           end
    end
    hash[:success_redirect]       ||= send("#{controller_name}_url")

    notice hash[:success_msg]
    redirect_to hash[:success_redirect] and return
  end

  def process_error hash = {}
    hash[:object] ||= instance_variable_get("@#{controller_name.singularize}")

    case action_name
    when "create" then hash[:render] ||= "new"
    when "update" then hash[:render] ||= "edit"
    else
      hash[:redirect] ||= send("#{controller_name}_url")
    end

    logger.info "Failed to save: #{hash[:object].errors.full_messages.join(", ")}" if hash[:object].respond_to?(:errors)
    hash[:error_msg] ||= [hash[:object].errors[:base] + hash[:object].errors[:conflict].map{|e| _("Conflict - %s") % e}].flatten
    hash[:error_msg] = [hash[:error_msg]].flatten
    hash[:error_msg] = hash[:error_msg].join("<br/>")
    if hash[:render]
      flash.now[:error] = hash[:error_msg] unless hash[:error_msg].empty?
      render hash[:render]
      return
    elsif hash[:redirect]
      error(hash[:error_msg]) unless hash[:error_msg].empty?
      redirect_to hash[:redirect]
      return
    end
  end

  def redirect_back_or_to url
    redirect_to request.referer.empty? ? url : :back
  end

  def generic_exception(exception)
    logger.warn "Operation FAILED: #{exception}"
    logger.debug exception.backtrace.join("\n")
    render :template => "common/500", :layout => !request.xhr?, :status => 500, :locals => { :exception => exception}
  end

  def set_taxonomy
    return if User.current.nil?

    if SETTINGS[:organizations_enabled]
      orgs = Organization.my_organizations
      Organization.current = if orgs.count == 1 && !User.current.admin?
                               orgs.first
                             elsif session[:organization_id]
                               orgs.find_by_id(session[:organization_id])
                             else
                               nil
                             end
      warning _("Organization you had selected as your context has been deleted.") if (session[:organization_id] && Organization.current == nil)
    end

    if SETTINGS[:locations_enabled]
      locations = Location.my_locations
      Location.current = if locations.count == 1 && !User.current.admin?
                           locations.first
                         elsif session[:location_id]
                           locations.find_by_id(session[:location_id])
                         else
                           nil
                         end
      warning _("Location you had selected as your context has been deleted.") if (session[:location_id] && Location.current == nil)
    end
  end

  def check_empty_taxonomy
    return if ["locations","organizations"].include?(controller_name)

    if User.current && User.current.admin?
      if SETTINGS[:locations_enabled] && Location.unconfigured?
        redirect_to main_app.locations_path, :notice => _("You must create at least one location before continuing.")
      elsif SETTINGS[:organizations_enabled] && Organization.unconfigured?
        redirect_to main_app.organizations_path, :notice => _("You must create at least one organization before continuing.")
      end
    end
  end

  # Returns the associations to include when doing a search.
  # If the user has a fact_filter then we need to include :fact_values
  # We do not include most associations unless we are processing a html page
  def included_associations(include = [])
    include += [:hostgroup, :compute_resource, :operatingsystem, :environment, :model ]
    include += [:fact_values] if User.current.user_facts.any?
    include
  end

  def errors_hash errors
    errors.any? ? {:status => N_("Error"), :message => errors.full_messages.join('<br>')} : {:status => N_("OK"), :message =>""}
  end

end
