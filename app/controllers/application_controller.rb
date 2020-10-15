class ApplicationController < ActionController::Base
  include ApplicationShared

  include Foreman::Controller::Flash
  include Foreman::Controller::Authorize
  include Foreman::Controller::RequireSsl

  protect_from_forgery with: :exception # See ActionController::RequestForgeryProtection for details
  rescue_from Exception, :with => :generic_exception if Rails.env.production?
  rescue_from ScopedSearch::QueryNotSupported, :with => :invalid_search_query
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ProxyAPI::ProxyException, :with => :smart_proxy_exception
  rescue_from Foreman::MaintenanceException, :with => :service_unavailable
  rescue_from ActiveRecord::SubclassNotFound, :with => :sti_clean_up

  # standard layout to all controllers
  helper 'layout'
  helper_method :resource_path

  before_action :load_settings
  before_action :require_login, :check_user_enabled
  before_action :set_gettext_locale_db, :set_gettext_locale
  before_action :session_expiry, :update_activity_time, :unless => proc { |c| c.remote_user_provided? || c.api_request? }
  before_action :set_taxonomy, :require_mail, :check_empty_taxonomy
  before_action :authorize
  before_action :welcome, :only => :index, :unless => :api_request?
  prepend_before_action :allow_webpack, if: -> { Rails.configuration.webpack.dev_server.enabled }
  around_action :set_timezone

  attr_reader :original_search_parameter

  def welcome
    return if model_of_controller&.any?
    if template_exists?(:welcome, _prefixes, variants: request.variant)
      @welcome = true
      render :welcome
    end
  end

  def api_request?
    request.format.try(:json?) || request.format.try(:yaml?)
  end

  # this method is returns the active user which gets used to populate the audits table
  def current_user
    User.current
  end

  def resource_path(type)
    return '' if type.nil?

    path = type.pluralize.underscore + "_path"
    prefix, suffix = path.split('/', 2)
    if path.include?("/") && Rails.application.routes.mounted_helpers.method_defined?(prefix)
      # handle mounted engines
      engine = send(prefix)
      engine.send(suffix) if engine.respond_to?(suffix)
    else
      path = path.tr("/", "_")
      send(path) if respond_to?(path)
    end
  end

  protected

  # Authorize the user for the requested action
  def authorize
    unless User.current.present?
      render :json => { :error => "Authentication error" }, :status => :unauthorized
      return
    end
    authorized ? true : deny_access
  end

  def deny_access
    (User.current.logged? || request.xhr?) ? render_403 : require_login
  end

  # This filter is called before FastGettext set_gettext_locale and sets user-defined locale
  # from db. It must be called after require_login.
  def set_gettext_locale_db
    params[:locale] ||= User.current.try(:locale)
  end

  def require_mail
    if User.current && !User.current.hidden? && User.current.mail.blank?
      msg = _("An email address is required, please update your account details")
      respond_to do |format|
        format.html do
          error msg
          flash.keep # keep any warnings added by the user login process, they may explain why this occurred
          redirect_to main_app.edit_user_path(:id => User.current)
        end
        format.text do
          render :plain => msg, :status => :unprocessable_entity, :content_type => Mime[:text]
        end
      end
      true
    end
  end

  def invalid_request
    render :plain => _('Invalid query'), :status => :bad_request
  end

  def not_found(exception = nil)
    logger.debug "not found: #{exception}" if exception
    respond_to do |format|
      format.html { render "common/404", :status => :not_found }
      format.any { head :not_found }
    end
    true
  end

  def service_unavailable(exception = nil)
    logger.debug "service unavailable: #{exception}" if exception
    respond_to do |format|
      format.html { render "common/503", :status => :service_unavailable, :locals => { :exception => exception } }
      format.any { head :service_unavailable }
    end
    true
  end

  def sti_clean_up(e)
    require_login rescue false
    Foreman::Logging.exception("Action failed", e) unless User.current&.admin?
    @unknown_class_name = e.message.match(/subclass: '(.*)'\./)[1]
    @parent_class = e.message.match(/overwrite (.*)\.inheritance_column/)[1].constantize
    if params[:confirm_data_deletion] == 'yes' && User.current&.admin?
      begin
        @parent_class.where(@parent_class.inheritance_column => @unknown_class_name).delete_all
      rescue ActiveRecord::InvalidForeignKey => e
        Foreman::Logging.exception("Error during STI data cleanup", e)
        render 'common/class_clean_up_failed'
        return
      end
      flash[:success] = _('Data has been cleaned up')
      redirect_back fallback_location: root_path
    else
      render 'common/confirm_class_clean_up'
    end
  end

  def smart_proxy_exception(exception = nil)
    Foreman::Logging.exception("ProxyAPI operation FAILED", exception)
    if request.headers.include? 'HTTP_REFERER'
      process_error(:redirect => :back, :error_msg => exception.message)
    else
      process_error(:render => { :plain => exception.message },
                    :error_msg => exception.message)
    end
  end

  # this method sets the Current user to be the Admin
  # its required for actions which are not authenticated by default
  # such as unattended notifications coming from an OS, or fact and reports creations
  def set_admin_user
    User.current = User.anonymous_api_admin
  end

  def model_of_controller
    @model_of_controller ||= controller_path.singularize.camelize.gsub('/', '::').safe_constantize
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

  # Not all models include Authorizable so we detect whether we should apply authorized scope or not
  def resource_base
    @resource_base ||= if model_of_controller.respond_to?(:authorized)
                         model_of_controller.authorized(current_permission)
                       else
                         model_of_controller.all
                       end
  end

  # this method is used with nested resources, where obj_id is passed into the parameters hash.
  # it automatically updates the search text box with the relevant relationship
  # e.g. /hosts/fqdn/reports # would add host = fqdn to the search bar
  def setup_search_options
    @original_search_parameter = params[:search]
    params[:search] ||= ""
    params.keys.each do |param|
      if param =~ /(\w+)_id$/
        if params[param].present?
          query = "#{Regexp.last_match(1)} = #{params[param]}"
          unless params[:search].include? query
            params[:search] += ' and ' if params[:search].present?
            params[:search] += query
          end
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
    return false if api_request? && !(Setting["authorize_login_delegation_api"])
    (@remote_user = request.env["HTTP_REMOTE_USER"]).present?
  end

  def resource_base_with_search
    resource_base.search_for(params[:search], :order => params[:order])
  end

  def resource_base_search_and_page(tables = [])
    base = tables.empty? ? resource_base_with_search : resource_base_with_search.eager_load(*tables)
    base.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  private

  def require_admin
    unless User.current.admin?
      render_403(_('Administrator user account required'))
      return false
    end
    true
  end

  def render_403(msg = nil)
    if msg.nil?
      @missing_permissions = Foreman::AccessControl.permissions_for_controller_action(path_to_authenticate)
      Foreman::Logging.logger('permissions').info "rendering 403 because of missing permission #{@missing_permissions.map(&:name).join(', ')}"
    else
      @missing_permissions = []
      Foreman::Logging.logger('permissions').info msg
    end

    respond_to do |format|
      format.html { render :template => "common/403", :layout => !ajax?, :status => :forbidden }
      format.any  { head :forbidden }
    end
    false
  end

  # this is only used in hosts_controller (by SmartProxyAuth module) to render 403's
  def render_error(msg, status)
    render_403(msg)
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
    hash[:success_redirect] ||= saved_redirect_url_or(send("#{controller_name}_url"))

    success hash[:success_msg]
    if hash[:success_redirect] == :back
      redirect_back(fallback_location: saved_redirect_url_or(send("#{controller_name}_url")))
    else
      redirect_to hash[:success_redirect]
    end
  end

  def process_error(hash = {})
    hash[:object] ||= instance_variable_get("@#{controller_name.singularize}")
    if hash[:render].blank? && hash[:redirect].blank?
      case action_name
      when "create" then hash[:render] = "new"
      when "update" then hash[:render] = "edit"
      else
        hash[:redirect] = send("#{controller_name}_url")
      end
    end

    logger.error "Failed to save: #{hash[:object].errors.full_messages.join(', ')}" if hash[:object].respond_to?(:errors)
    hash[:error_msg] ||= [hash[:object].errors[:base] + hash[:object].errors[:conflict].map { |e| _("Conflict - %s") % e }].flatten
    hash[:error_msg] = [hash[:error_msg]].flatten.to_sentence
    if hash[:render]
      error(hash[:error_msg], true) unless hash[:error_msg].empty?
      render hash[:render]
    elsif hash[:redirect]
      error(hash[:error_msg]) unless hash[:error_msg].empty?
      if hash[:redirect] == :back
        redirect_back(fallback_location: send("#{controller_name}_url"))
      else
        redirect_to hash[:redirect]
      end
    end
  end

  def process_ajax_error(exception, action = nil)
    action ||= action_name
    origin = exception.original_exception if exception.present? && exception.respond_to?(:original_exception)
    Foreman::Logging.exception("Failed to #{action}", exception)
    Foreman::Logging.exception("Originally caused by", origin) if origin
    message = (origin || exception).message

    render :partial => "common/ajax_error", :status => :internal_server_error, :locals => { :message => message }
  end

  def redirect_back_or_to(url)
    redirect_back(fallback_location: url)
  end

  def saved_redirect_url_or(default)
    session["redirect_to_url_#{controller_name}"] || default
  end

  def generic_exception(exception)
    if exception.try(:cause).is_a?(ActiveRecord::SubclassNotFound)
      sti_clean_up(exception.cause)
    else
      ex_message = exception.message
      Foreman::Logging.exception(ex_message, exception)
      full_request_id = request.request_id
      render :template => "common/500", :layout => !request.xhr?, :status => :internal_server_error, :locals => { exception_message: ex_message, request_id: full_request_id.split('-').first, full_request_id: full_request_id }
    end
  end

  def check_empty_taxonomy
    return if ["locations", "organizations"].include?(controller_name)

    if User.current&.admin?
      if Location.unconfigured?
        redirect_to main_app.locations_path, :info => _("You must create at least one location before continuing.")
      elsif Organization.unconfigured?
        redirect_to main_app.organizations_path, :info => _("You must create at least one organization before continuing.")
      end
    end
  end

  # Returns the associations to include when doing a search.
  # If the user has a fact_filter then we need to include :fact_values
  # We do not include most associations unless we are processing a html page
  def included_associations(include = [])
    include + [:hostgroup, :compute_resource, :operatingsystem, :model, :host_statuses, :token]
  end

  def errors_hash(errors)
    errors.any? ? {:status => N_("Error"), :message => errors.full_messages.join('<br>')} : {:status => N_("OK"), :message => ""}
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

    @organization ||= Organization.current
    @location     ||= Location.current
  end

  def parameter_filter_context
    Foreman::ParameterFilter::Context.new(:ui, controller_name, params[:action])
  end

  def allow_webpack
    webpack_csp = {
      script_src: [webpack_server], connect_src: [webpack_server],
      style_src: [webpack_server], img_src: [webpack_server],
      font_src: ["data: #{webpack_server}"], default_src: [webpack_server]
    }

    append_content_security_policy_directives(webpack_csp)
  end

  def webpack_server
    port = Rails.configuration.webpack.dev_server.port
    @dev_server ||= "#{request.protocol}#{request.host}:#{port}"
  end

  class << self
    def parameter_filter_context
      Foreman::ParameterFilter::Context.new(:ui, controller_name, nil)
    end
  end
end
