module Api
  # TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base
    include ApplicationShared
    include Foreman::Controller::ApiCsrfProtection
    include Foreman::Controller::BruteforceProtection

    before_action :load_settings
    before_action :set_default_response_format, :authorize, :set_taxonomy
    before_action :assign_lone_taxonomies, :only => :create
    before_action :add_info_headers, :set_gettext_locale
    before_action :session_expiry, :update_activity_time
    around_action :set_timezone

    respond_to :json

    after_action :log_response_body

    rescue_from StandardError do |error|
      Foreman::Logging.exception("Action failed", error)
      render_error 'standard_error', :status => :internal_server_error, :locals => { :exception => error }
    end

    rescue_from NoMethodError do |error|
      Foreman::Logging.exception("Action failed", error)
      message = _("Internal Server Error: the server was unable to finish the request. ")
      message << _("This may be caused by unavailability of some required service, incorrect API call or a server-side bug. ")
      message << _("There may be more information in the server's logs.")
      render_error 'custom_error', :status => :internal_server_error, :locals => { :message => message }
    end

    rescue_from ScopedSearch::QueryNotSupported, Apipie::ParamError do |error|
      logger.info "#{error.message} (#{error.class})"
      render_error 'param_error', :status => :bad_request, :locals => { :exception => error }
    end

    rescue_from ActiveRecord::RecordNotFound do |error|
      logger.info "#{error.message} (#{error.class})"
      if error.model == resource_class.model_name.name || error.model.nil?
        not_found
      elsif (error.model.include? resource_class.model_name.name) || (resource_class.model_name.name.include? error.model)
        not_found
      else
        association_not_found(error)
      end
    end

    rescue_from Foreman::AssociationNotFound do |error|
      logger.info "#{error.message} (#{error.class})"
      association_not_found(error)
    end

    rescue_from Foreman::MaintenanceException, :with => :service_unavailable

    def get_resource(message = "Couldn't find resource")
      instance_variable_get(:"@#{resource_name}") || raise(message)
    end

    helper_method :controller_permission

    def controller_permission
      controller_name
    end

    # overwrites resource_scope in FindCommon to consider nested objects
    def resource_scope(options = {})
      super(options).merge(parent_scope).readonly(false)
    end

    def parent_scope
      parent_name, scope = parent_resource_details

      return resource_class.all unless scope

      association = resource_class.reflect_on_all_associations.detect { |assoc| assoc.plural_name == parent_name.pluralize }
      # if couldn't find an association by name, try to find one by class
      association ||= resource_class.reflect_on_all_associations.detect { |assoc| assoc.class_name == parent_name.camelize }
      if association.nil? && parent_name == 'host'
        association = resource_class.reflect_on_all_associations.detect { |assoc| assoc.class_name == 'Host::Base' }
      end
      return resource_class.all if association.nil? && Taxonomy.types.include?(resource_class_for(resource_name(parent_name)))
      raise "Association not found for #{parent_name}" unless association
      result_scope = resource_class_join(association, scope).reorder(nil)
      # Check that the scope resolves before return
      result_scope.any?
      result_scope
    rescue ActiveRecord::ConfigurationError
      # Chaining SQL with a parent scope does not always work, as the
      # parent scope might have attributes the resource_class does not have.
      #
      # For example, chaining 'interfaces' with a parent scope (hosts) that
      # contains an authorization filter (hostgroup = foo), will not work
      # as the resulting SQL has attributes (hostgroup) the
      # resource_class does not have.
      #
      # In such cases, we resolve the scope first, and then call 'where'
      # on the results
      resource_class.joins(association.name).
        where(association.name => scope.select(:id))
    end

    def resource_class_join(association, scope)
      resource_class.joins(association.name).merge(scope)
    end

    def resource_scope_for_index(options = {})
      scope = resource_scope(options).search_for(*search_options)
      return scope if paginate_options[:per_page] == 'all'
      scope.paginate(paginate_options)
    end

    def api_request?
      true
    end

    protected

    def not_found(options = nil)
      not_found_message = {}

      case options
      when String
        not_found_message[:message] = options
      when Hash
        not_found_message.merge! options
      else
        render_error 'not_found', :status => :not_found
        return false
      end

      render :json => not_found_message, :status => :not_found

      false
    end

    def association_not_found(error)
      render_error 'custom_error', :status => :unprocessable_entity, :locals => { :message => error.message }
    end

    def service_unavailable(exception = nil)
      logger.debug "service unavailable: #{exception}" if exception
      render_exception(exception, :status => :service_unavailable)
    end

    def process_resource_error(options = { })
      resource = options[:resource] || get_resource(options[:message])

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

    def render_exception(exception, render_options = {})
      Foreman::Logging.exception(exception.to_s, exception)
      render_message(exception.to_s, render_options)
    end

    def log_resource_errors(resource)
      logger.error "Unprocessable entity #{resource.class.name} (id: #{resource.try(:id) || 'new'}):\n  #{resource.errors.full_messages.join("\n  ")}\n"
    end

    def authorize
      if bruteforce_attempt?
        log_bruteforce
        render_error('bruteforce_attempt', :status => :unauthorized)
        return false
      end

      unless authenticate
        count_login_failure
        render_error('unauthorized', :status => :unauthorized, :locals => { :user_login => @available_sso.try(:user) })
        return false
      end

      if User.current&.disabled?
        render_error('custom_error', status: :unauthorized, locals: {message: _('User account is disabled, please contact your administrator')})
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
        false
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
      options = set_error_details(error, options)
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

    def assign_lone_taxonomies
      return unless resource_class_for(resource_name)
      # parameters aren't taxable but have a relation to taxonomies because of location and organization params
      return if resource_name.ends_with? 'parameter'
      # reports have a relationship to taxonomies through the host, not directly
      return if resource_class.ancestors.include? Report
      return if resource_class == Filter
      Taxonomy.types.each do |taxonomy|
        tax_name = taxonomy.to_s.downcase
        if resource_class.reflections.has_key? tax_name.pluralize
          tax_ids = "#{tax_name}_ids"
          next if params[resource_name].try(:has_key?, tax_ids)
          next unless taxonomy.one?
          params[resource_name][tax_ids] = [taxonomy.first.id]
        elsif resource_class.reflections.has_key? tax_name
          tax_id = "#{tax_name}_id"
          next if params[resource_name].try(:has_key?, tax_id)
          next unless taxonomy.one?
          params[resource_name][tax_id] = taxonomy.first.id
        end
      end
    end

    def add_version_header
      response.headers["Foreman_version"] = SETTINGS[:version].full
      response.headers["Foreman_api_version"] = api_version
    end

    def add_taxonomies_header
      current_org = "#{Organization.current.id}; #{Organization.current.name}" if Organization.current
      response.headers["Foreman_current_organization"] = current_org || '; ANY'
      current_loc = "#{Location.current.id}; #{Location.current.name}" if Location.current
      response.headers["Foreman_current_location"] = current_loc || '; ANY'
    end

    def add_info_headers
      add_version_header
      add_taxonomies_header
    end

    # this method is used with nested resources, where obj_id is passed into the parameters hash.
    # it automatically updates the search text box with the relevant relationship
    # e.g. /hosts/fqdn/reports # would add host = fqdn to the search bar
    def setup_search_options
      params[:search] ||= ""
      params.keys.each do |param|
        if param =~ /(\w+)_id$/
          if params[param].present?
            query = " #{Regexp.last_match(1)} = #{params[param]}"
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
        # this method does not reliably work when you have multiple parameters and some of them can be nil
        # find_nested_object in such case returns nil (since org and loc can be nil for any context),
        # but it detects other paramter which can have value set
        # therefore we always skip these
        next if ['organization_id', 'location_id'].include?(obj_id)
        if params[obj_id].present?
          not_found _("%{resource_name} not found by id '%{id}'") % { :resource_name => obj_id.humanize, :id => params[obj_id] }
          return
        end
      end
    end

    def missing_permissions
      Foreman::AccessControl.permissions_for_controller_action(path_to_authenticate)
    end

    def set_error_details(error, options)
      case error
      when 'access_denied'
        fail_message = _('Missing one of the required permissions: %s') % missing_permissions.map(&:name).join(', ')
        Foreman::Logging.logger('permissions').info fail_message
        if options.fetch(:locals, {}).fetch(:details, nil).blank?
          options = options.deep_merge({:locals => {:details => fail_message, :missing_permissions => missing_permissions.map(&:name)}})
        end
      end
      options
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
      params.select { |param| param.ends_with?('_id') }.each do |param, value|
        parent_id = value
        parent_name = param.delete_suffix('_id')
        parent_class = resource_class_for(resource_name(parent_name))
        break if parent_class
      end

      return nil if parent_name.nil? || parent_class.nil?
      # for admin we don't want to add any context condition, that would fail for hosts since we'd add join to
      # taxonomy table without any condition, inner join would return no host in this case
      return nil if User.current.admin? && Taxonomy.types.include?(parent_class) && parent_id.blank?
      # for taxonomies, nil is valid value which indicates, we need to search in Users all taxonomies
      return [parent_name, User.current.my_organizations] if parent_class == Organization && parent_id.blank?
      return [parent_name, User.current.my_locations] if parent_class == Location && parent_id.blank?

      parent_scope = scope_for(parent_class, :permission => "#{parent_permission(action_permission)}_#{parent_name.pluralize}")
      parent_scope = scope_by_resource_id(parent_scope, parent_id)
      [parent_name, parent_scope]
    end

    def parameter_filter_context
      Foreman::ParameterFilter::Context.new(:api, controller_name, params[:action])
    end

    class << self
      def parameter_filter_context
        Foreman::ParameterFilter::Context.new(:api, controller_name, nil)
      end

      protected

      def add_scoped_search_description_for(resource)
        search_fields = resource.scoped_search_definition.fields.map do |k, f|
          info = { :name => k.to_s }
          if f.complete_value.is_a?(Hash)
            info[:values] = f.complete_value.keys
          else
            # type is unknown for fields that are delegated to external methods
            # 'string' is a good guess in such cases
            info[:type] = f.ext_method.nil? ? f.type.to_s : 'string' rescue ''
          end
          info
        end
        meta :search => search_fields.sort_by { |info| info[:name] }
      end
    end
  end
end
