module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base

    before_filter :set_default_response_format, :authorize

    respond_to :json

    after_filter do
      logger.debug "Body: #{response.body}"
    end

    rescue_from StandardError, :with => lambda { |error|
      Rails.logger.error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
      render_error 'standard_error', :status => 500, :locals => { :exception => error }
    }

    rescue_from Apipie::ParamError, :with => lambda { |error|
      Rails.logger.info "#{error.message} (#{error.class})"
      render_error 'param_error', :status => :bad_request, :locals => { :exception => error }
    }


    def get_resource
      instance_variable_get :"@#{resource_name}" or raise 'no resource loaded'
    end

    def resource_name
      controller_name.singularize
    end

    def resource_class
      @resource_class ||= resource_name.camelize.constantize
    end

    protected

    def process_resource_error(options = { })
      resource = options[:resource] || get_resource

      raise 'resource have no errors' if resource.errors.empty?

      if resource.permission_failed?
        deny_access
      else
        render_error 'unprocessable_entity', :status => :unprocessable_entity
      end
    end

    def process_success(response = nil)
      response ||= get_resource
      respond_with response
    end

    def process_response(condition, response = nil)
      if condition
        process_success response
      else
        process_resource_error
      end
    end

    def authorize
      auth = Api::Authorization.new self

      unless auth.authenticate
        render_error('unauthorized', :status => :unauthorized, :locals => { :user_login => auth.user_login })
        return false
      end

      unless auth.authorize
        deny_access
        return false
      end

      return true
    end

    def deny_access(details = nil)
      render_error 'access_denied', :status => :forbidden, :locals => { :details => details }
      false
    end

    # searches for a resource based on its name and assign it to an instance variable
    # required for models which implement the to_param method
    #
    # example:
    # @host = Host.find_resource params[:id]
    def find_resource
      resource = resource_identifying_attributes.find do |key|
        method = "find_by_#{key}"
        resource_class.respond_to?(method) and
            (resource = resource_class.send method, params[:id]) and
            break resource
      end

      if resource
        return instance_variable_set(:"@#{resource_name}", resource)
      else
        render_error 'not_found', :status => :not_found and
            return false
      end
    end

    def resource_identifying_attributes
      %w(id name)
    end

    def set_default_response_format
      request.format = :json if params[:format].nil?
    end

    def api_version
      raise NotImplementedError
    end

    def render_error(error, options = { })
      render options.merge(:template => "/api/v#{api_version}/errors/#{error}")
    end
  end
end
