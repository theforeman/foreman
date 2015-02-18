class ApplicationController < ActionController::Base
  include ApplicationShared

  ensure_security_headers
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  rescue_from ScopedSearch::QueryNotSupported, :with => :invalid_search_query
  rescue_from Exception, :with => :generic_exception if Rails.env.production?
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActionView::MissingTemplate, :with => :api_deprecation_error

  # standard layout to all controllers
  helper 'layout'
  helper_method :authorizer

  before_filter :require_ssl, :require_login
  before_filter :set_gettext_locale_db, :set_gettext_locale
  before_filter :session_expiry, :update_activity_time, :unless => proc {|c| !SETTINGS[:login] || c.remote_user_provided? || c.api_request? }
  before_filter :set_taxonomy, :require_mail, :check_empty_taxonomy
  before_filter :authorize
  before_filter :welcome, :only => :index, :unless => :api_request?
  around_filter :set_timezone
  layout :display_layout?

  attr_reader :original_search_parameter

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
    request.format.try(:json?) || request.format.try(:yaml?)
  end

  # this method is returns the active user which gets used to populate the audits table
  def current_user
    User.current
  end

  protected

  # Authorize the user for the requested action
  def authorize
    (render :json => { :error => "Authentication error" }, :status => :unauthorized and return) unless User.current.present?
    authorized ? true : deny_access
  end

  def authorizer
    @authorizer ||= Authorizer.new(User.current, :collection => instance_variable_get("@#{controller_name}"))
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
    redirect_to :protocol => 'https' and return if request.protocol != 'https://' and not request.ssl?
  end

  # This filter is called before FastGettext set_gettext_locale and sets user-defined locale
  # from db. It must be called after require_login.
  def set_gettext_locale_db
    params[:locale] ||= User.current.try(:locale)
  end

  def require_mail
    if User.current && !User.current.hidden? && User.current.mail.blank?
      notice _("Mail is Required")
      redirect_to edit_user_path(:id => User.current)
    end
  end

  def invalid_request
    render :text => _('Invalid query'), :status => :bad_request
  end

  def not_found(exception = nil)
    logger.debug "not found: #{exception}" if exception
    respond_to do |format|
      format.html { render "common/404", :status => :not_found }
      format.any { head :status => :not_found}
    end
    true
  end

  def api_deprecation_error(exception = nil)
    if request.format.try(:json?) && !request.env['REQUEST_URI'].match(/\/api\//i)
      logger.error "#{exception.message} (#{exception.class})\n#{exception.backtrace.join("\n")}"
      msg = "/api/ prefix must now be used to access API URLs, e.g. #{request.env['HTTP_HOST']}/api#{request.env['REQUEST_URI']}"
      logger.error "DEPRECATION: #{msg}."
      render :json => {:message => msg}, :status => :bad_request
    else
      raise exception
    end
  end

  # this method sets the Current user to be the Admin
  # its required for actions which are not authenticated by default
  # such as unattended notifications coming from an OS, or fact and reports creations
  def set_admin_user
    User.current = User.anonymous_api_admin
  end

  def model_of_controller
    @model_of_controller ||= controller_path.singularize.camelize.gsub('/','::').constantize
  end

  def current_permission
    [action_permission, controller_permission].join('_')
  end

  def controller_permission
    controller_name
  end

  def action_permission
    case params[:action]
      when 'new', 'create'
        'create'
      when 'edit', 'update'
        'edit'
      when 'destroy'
        'destroy'
      when 'index', 'show'
        'view'
      else
        raise ::Foreman::Exception.new(N_("unknown permission for %s"), "#{params[:controller]}##{params[:action]}")
    end
  end

  # not all models includes Authorizable so we detect whether we should apply authorized scope or not
  def resource_base
    @resource_base ||= model_of_controller.respond_to?(:authorized) ?
        model_of_controller.authorized(current_permission) :
        model_of_controller.scoped
  end

  def notice(notice)
    flash[:notice] = CGI::escapeHTML(notice)
  end

  def error(error)
    flash[:error] = CGI::escapeHTML(error)
  end

  def warning(warning)
    flash[:warning] = CGI::escapeHTML(warning)
  end

  # this method is used with nested resources, where obj_id is passed into the parameters hash.
  # it automatically updates the search text box with the relevant relationship
  # e.g. /hosts/fqdn/reports # would add host = fqdn to the search bar
  def setup_search_options
    @original_search_parameter = params[:search]
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

  def display_layout?
    return nil if two_pane?
    "application"
  end

  private

  def require_admin
    unless User.current.admin?
      render_403
      return false
    end
    true
  end

  def render_403
    respond_to do |format|
      format.html { render :template => "common/403", :layout => !request.xhr?, :status => :forbidden }
      format.any  { head :forbidden }
    end
    false
  end

  # this is only used in hosts_controller (by SmartProxyAuth module) to render 403's
  def render_error(msg, status)
    render_403
  end

  def process_success(hash = {})
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
    hash[:success_redirect]       ||= saved_redirect_url_or(send("#{controller_name}_url"))

    notice hash[:success_msg]
    redirect_to hash[:success_redirect] and return
  end

  def process_error(hash = {})
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
    hash[:error_msg] = hash[:error_msg].to_sentence
    if hash[:render]
      flash.now[:error] = CGI::escapeHTML(hash[:error_msg]) unless hash[:error_msg].empty?
      render hash[:render]
      return
    elsif hash[:redirect]
      error(hash[:error_msg]) unless hash[:error_msg].empty?
      redirect_to hash[:redirect]
      return
    end
  end

  def process_ajax_error(exception, action = nil)
    action ||= action_name
    origin = exception.original_exception if exception.present? && exception.respond_to?(:original_exception)
    message = (origin || exception).message
    logger.warn "Failed to #{action}: #{message}"
    logger.debug "Original exception backtrace:\n" + origin.backtrace.join("\n") if origin.present?
    logger.debug "Causing backtrace:\n" + exception.backtrace.join("\n")
    render :json => _("Failure: %s") % message, :status => :internal_server_error
  end

  def redirect_back_or_to(url)
    redirect_to request.referer.empty? ? url : :back
  end

  def saved_redirect_url_or(default)
    session["redirect_to_url_#{controller_name}"] || default
  end

  def generic_exception(exception)
    logger.warn "Operation FAILED: #{exception}"
    logger.debug exception.backtrace.join("\n")
    render :template => "common/500", :layout => !request.xhr?, :status => :internal_server_error, :locals => { :exception => exception}
  end

  def set_taxonomy
    return if User.current.nil?

    if SETTINGS[:organizations_enabled]
      orgs = Organization.my_organizations
      Organization.current = if orgs.count == 1 && !User.current.admin?
                               orgs.first
                             elsif session[:organization_id]
                               orgs.find_by_id(session[:organization_id])
                             end
      warning _("Organization you had selected as your context has been deleted.") if (session[:organization_id] && Organization.current == nil)
    end

    if SETTINGS[:locations_enabled]
      locations = Location.my_locations
      Location.current = if locations.count == 1 && !User.current.admin?
                           locations.first
                         elsif session[:location_id]
                           locations.find_by_id(session[:location_id])
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
    include
  end

  def errors_hash(errors)
    errors.any? ? {:status => N_("Error"), :message => errors.full_messages.join('<br>')} : {:status => N_("OK"), :message =>""}
  end

  def taxonomy_scope
    if params[controller_name.singularize.to_sym]
      @organization = Organization.find_by_id(params[controller_name.singularize.to_sym][:organization_id])
      @location     = Location.find_by_id(params[controller_name.singularize.to_sym][:location_id])
    end

    if instance_variable_get("@#{controller_name}").present?
      @organization ||= instance_variable_get("@#{controller_name}").organization
      @location     ||= instance_variable_get("@#{controller_name}").location
    end

    @organization ||= Organization.find_by_id(params[:organization_id]) if params[:organization_id]
    @location     ||= Location.find_by_id(params[:location_id])         if params[:location_id]

    @organization ||= Organization.current if SETTINGS[:organizations_enabled]
    @location     ||= Location.current if SETTINGS[:locations_enabled]
  end

  def two_pane?
    request.headers["X-Foreman-Layout"] == 'two-pane' && params[:action] != 'index'
  end

  # Called from ActionController::RequestForgeryProtection, overrides
  # nullify session which is the default behavior for unverified requests in Rails 3.
  # On Rails 4 we can get rid of this and use the strategy ':exception'.
  def handle_unverified_request
    raise ::Foreman::Exception.new(N_("Invalid authenticity token"))
  end
end
