module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base
    include ApplicationShared

    protect_from_forgery
    force_ssl :if => :require_ssl?
    skip_before_filter :verify_authenticity_token, :unless => :protect_api_from_forgery?

    before_filter :set_default_response_format, :authorize, :add_version_header, :set_gettext_locale
    before_filter :session_expiry, :update_activity_time
    around_filter :set_timezone

    cache_sweeper :topbar_sweeper

    respond_to :json

    after_filter :log_response_body

    rescue_from StandardError do |error|
      Foreman::Logging.exception("Action failed", error)
      render_error 'standard_error', :status => :internal_server_error, :locals => { :exception => error }
    end

    rescue_from ScopedSearch::QueryNotSupported, Apipie::ParamError do |error|
      logger.info "#{error.message} (#{error.class})"
      render_error 'param_error', :status => :bad_request, :locals => { :exception => error }
    end

    rescue_from ActiveRecord::RecordNotFound do |error|
      logger.info "#{error.message} (#{error.class})"
      not_found
    end

    def get_resource
      instance_variable_get :"@#{resource_name}" or raise 'no resource loaded'
    end

    def controller_permission
      controller_name
    end

    # overwrites resource_scope in FindCommon to consider nested objects
    def resource_scope(options = {})
      child_scope = super(options)
      child_scope.merge(parent_scope).readonly(false)
    end

    def parent_scope
      parent_name, scope = parent_resource_details

      return resource_class.all unless scope

      association = resource_class.reflect_on_all_associations.find {|assoc| assoc.plural_name == parent_name.pluralize}
      resource_class.joins(association.name).merge(scope)
    end

    def resource_scope_for_index(options = {})
      resource_scope(options).search_for(*search_options).paginate(paginate_options)
    end

    def api_request?
      true
    end

    protected

    def require_ssl?
      SETTINGS[:require_ssl]
    end

    def not_found(options = nil)
      not_found_message = {}

      case options
      when String
        not_found_message.merge! :message => options
      when Hash
        not_found_message.merge! options
      else
        render_error 'not_found', :status => :not_found and return false
      end

      render :json => not_found_message, :status => :not_found and return false
    end

    def process_resource_error(options = { })
      resource = options[:resource] || get_resource

      raise 'resource have no errors' if resource.errors.empty?

      if resource.respond_to?(:permission_failed?) && resource.permission_failed?
        deny_access
      else
        log_resource_errors resource
        render_error 'unprocessable_entity', :status => :unprocessable_entity
      end
    end

    def process_success(response = nil)
      render_status = request.post? ? :created : :ok
      response ||= get_resource
      respond_with response, :responder => ApiResponder, :status => render_status
    end

    def process_response(condition, response = nil)
      if condition
        process_success response
      else
        process_resource_error
      end
    end

    def render_message(msg, render_options = {})
      render_options[:json] = { :message => msg }
      render render_options
    end

    def log_resource_errors(resource)
      logger.error "Unprocessable entity #{resource.class.name} (id: #{resource.try(:id) || "new"}):\n  #{resource.errors.full_messages.join("\n  ")}\n"
    end

    def authorize
      unless authenticate
        render_error('unauthorized', :status => :unauthorized, :locals => { :user_login => @available_sso.try(:user) })
        return false
      end

      unless authorized
        deny_access
        return false
      end

      true
    end

    def require_admin
      unless is_admin?
        render_error('access_denied', :status => :unauthorized, :locals => { :details => _('Admin permissions required') })
        return false
      end
    end

    def set_admin_user
      User.current = User.anonymous_api_admin
    end

    def deny_access(details = nil)
      render_error 'access_denied', :status => :forbidden, :locals => { :details => details }
      false
    end

    def set_default_response_format
      request.format = :json if params[:format].blank?
    end

    def api_version
      raise NotImplementedError
    end

    def render_error(error, options = { })
      render options.merge(:template => "/api/v#{api_version}/errors/#{error}")
    end

    def search_options
      [params[:search], {:order => params[:order]}]
    end

    def paginate_options
      {
        :page     => params[:page],
        :per_page => params[:per_page],
      }
    end

    def add_version_header
      response.headers["Foreman_version"]= SETTINGS[:version].full
      response.headers["Foreman_api_version"]= api_version
    end

    # this method is used with nested resources, where obj_id is passed into the parameters hash.
    # it automatically updates the search text box with the relevant relationship
    # e.g. /hosts/fqdn/reports # would add host = fqdn to the search bar
    def setup_search_options
      params[:search] ||= ""
      params.keys.each do |param|
        if param =~ /(\w+)_id$/
          unless params[param].blank?
            query = " #{$1} = #{params[param]}"
            params[:search] += query unless params[:search].include? query
          end
        end
      end
    end

    def log_response_body
      logger.debug { "Body: #{response.body}" }
    end

    private

    attr_reader :nested_obj

    def find_required_nested_object
      find_nested_object
      return @nested_obj if @nested_obj
      not_found
    end

    def find_optional_nested_object
      find_nested_object
      return @nested_obj if @nested_obj
      not_found_if_nested_id_exists
    end

    def find_nested_object
      _parent_name, parent_resource_scope = parent_resource_details

      return if parent_resource_scope.nil?

      @nested_obj = parent_resource_scope.first
    end

    def not_found_if_nested_id_exists
      allowed_nested_id.each do |obj_id|
        if params[obj_id].present?
          not_found _("%{resource_name} not found by id '%{id}'") % { :resource_name => obj_id.humanize, :id => params[obj_id] }
        end
      end
    end

    protected

    # will be overwritten by each controller. initialize as empty array to prevent handling nil variable
    def allowed_nested_id
      []
    end
    # will be overwritten by each controller. initialize as empty array to prevent handling nil variable
    def skip_nested_id
      []
    end

    def action_permission
      case params[:action]
      when 'new', 'create'
        'create'
      when 'edit', 'update'
        'edit'
      when 'destroy'
        'destroy'
      when 'index', 'show', 'status'
        'view'
      else
        raise ::Foreman::Exception.new(N_("unknown permission for %s"), "#{params[:controller]}##{params[:action]}")
      end
    end

    def parent_permission(child_permission)
      case child_permission.to_s
      when 'create', 'destroy'
        'edit'
      when 'edit', 'view'
        'view'
      else
        raise ::Foreman::Exception.new(N_("unknown parent permission for %s"), "#{params[:controller]}##{child_permission}")
      end
    end

    def parent_resource_details
      parent_name, parent_class, parent_id = nil
      params.find do |param, value|
        parent_id = value
        parent_name, parent_class = extract_resource_from_param(param)
        parent_class
      end

      return nil if parent_name.nil?
      parent_scope = scope_for(parent_class, :permission => "#{parent_permission(action_permission)}_#{parent_name.pluralize}")
      parent_scope = select_by_resource_id_scope(parent_scope, parent_class, parent_id)
      [parent_name, parent_scope]
    end

    def extract_resource_from_param(param)
      md = param.match(/(\w+)_id$/)
      md ? [md[1], resource_class_for(resource_name(md[1]))] : nil
    end

    # This method adds a condition to the base_scope in form:
    # "resource_class.id = resource_id [ OR resource_class.friendly_id_column = resource_id ]"
    # the optional part will be added if the resource class supports friendly_id
    # it will also add "ORDER BY" query in order to prioritize
    # records with friendly_id_column hit rather than those that have filtered because of
    # id column filtering
    #Should be replaced after moving to friendly_id version >= 5.0
    def select_by_resource_id_scope(base_scope, resource_class, resource_id)
      arel = resource_class.arel_table
      arel_query = arel[:id].eq(resource_id)
      arel_query.to_sql
      begin
        query_field = resource_class.friendly_id_config.query_field
      rescue NoMethodError
        #FriendlyId is not supported (didn't find a better way to test it)
        # The problem is in Host <-> Host::Managed hack. #responds_to? query_field
        # will return false values.
        query_field = nil
      end

      if query_field
        friendly_field_query = arel[query_field].eq(resource_id)
        arel_query = arel_query.or(friendly_field_query)
      end

      filtered_scope = base_scope.where(arel_query)

      filtered_scope = prioritize_friendly_name_records(filtered_scope, friendly_field_query) if query_field

      filtered_scope
    end

    #Prefer records that matched the friendly column upon those matched the ID column
    def prioritize_friendly_name_records(base_scope, friendly_field_query)
      field_query = friendly_field_query.to_sql
      base_scope.order("CASE WHEN #{field_query} THEN 1 ELSE 0 END")
    end

    def protect_api_from_forgery?
      session[:user].present?
    end
  end
end
