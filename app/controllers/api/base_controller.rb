module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base
    include Foreman::Controller::Authentication
    include Foreman::Controller::Session
    include Foreman::ThreadSession::Cleaner

    protect_from_forgery
    skip_before_filter :verify_authenticity_token, :unless => :protect_api_from_forgery?

    before_filter :set_default_response_format, :authorize, :add_version_header, :set_gettext_locale
    before_filter :session_expiry, :update_activity_time

    cache_sweeper :topbar_sweeper

    respond_to :json

    after_filter :log_response_body

    rescue_from StandardError, :with => lambda { |error|
      logger.error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
      render_error 'standard_error', :status => :internal_server_error, :locals => { :exception => error }
    }

    rescue_from ScopedSearch::QueryNotSupported,
                Apipie::ParamError, :with => lambda { |error|
      logger.info "#{error.message} (#{error.class})"
      render_error 'param_error', :status => :bad_request, :locals => { :exception => error }
    }

    rescue_from ActiveRecord::RecordNotFound, :with => lambda { |error|
      logger.info "#{error.message} (#{error.class})"
      not_found(:message => "#{error.message}", :class => "#{error.class}")
    }


    def get_resource
      instance_variable_get :"@#{resource_name}" or raise 'no resource loaded'
    end

    def resource_name
      controller_name.singularize
    end

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    def resource_scope(controller = controller_name)
      @resource_scope ||= begin
        scope = resource_class.scoped
        if resource_class.respond_to?(:authorized)
          scope.authorized("#{action_permission}_#{controller}", resource_class)
        else
          scope
        end
      end
    end

    def api_request?
      true
    end

    protected

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
      response ||= get_resource
      respond_with response, :responder => ApiResponder
    end

    def process_response(condition, response = nil)
      if condition
        process_success response
      else
        process_resource_error
      end
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
        render_error('admin permissions required', :status => :unauthorized, :locals => { :user_login => @available_sso.try(:user) })
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

    # possible keys that should be used to find the resource
    def resource_identifying_attributes
      %w(name id)
    end

    # searches for a resource based on its name and assign it to an instance variable
    # required for models which implement the to_param method
    #
    # example:
    # @host = Host.find_resource params[:id]
    def find_resource(controller = controller_name)
      resource = resource_identifying_attributes.find do |key|
        next if key=='name' and (params[:id] =~ /\A\d+\z/)
        method = "find_by_#{key}"
        id = key=='id' ? params[:id].to_i : params[:id]
        scope = resource_scope(controller)
        if scope.respond_to?(method)
          (resource = scope.send method, id) and break resource
        end
      end

      if resource
        return instance_variable_set(:"@#{resource_name}", resource)
      else
        not_found
      end
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
      params.keys.each do |param|
        if md = param.match(/(\w+)_id$/)
          if allowed_nested_id.include?(param)
            resource_identifying_attributes.each do |key|
              find_method = "find_by_#{key}"
              model = md[1].classify.constantize
              controller = md[1].pluralize
              authorized_scope = model.authorized("#{action_permission}_#{controller}")
              @nested_obj ||= authorized_scope.send(find_method, params[param])
            end
          else
            # there should be a route error before getting here, but just in case,
            # throw an exception if a parameter 'xyz_id' was passed manually in URL string rather than generated by nested route.
            # unless it is explicitly declared in skip_nested_id in the case where there is 2-level nesting . Ex. puppetclasses/apache/smart_variables/4/override_values
            raise "#{param} is not allowed as nested parameter for #{controller_name}. Allowed parameters are #{allowed_nested_id.join(', ')}" unless skip_nested_id.include?(param)
          end
        end
      end
    end

    def not_found_if_nested_id_exists
      allowed_nested_id.each do |obj_id|
        if params[obj_id].present?
          not_found "#{obj_id.humanize} not found by id '#{params[obj_id]}'"
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

    def protect_api_from_forgery?
      session[:user].present?
    end
  end
end
