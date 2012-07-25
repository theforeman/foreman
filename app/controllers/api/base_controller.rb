require 'oauth/client/action_controller_request'

module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base

    before_filter :set_default_response_format, :authorize, :set_resource_params

    respond_to :json

    rescue_from StandardError, :with => lambda { |error|
      Rails.logger.error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
      render_error 'standard_error', :status => 500, :locals => { :exception => error }
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
      auth = Authorize.new self

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

    class Authorize
      attr_reader :controller, :user_login

      def initialize(controller)
        @controller = controller
      end

      def authenticate
        unless SETTINGS[:login]
          # We assume we always have a user logged in,
          # if authentication is disabled, the user is the build-in admin account.
          User.current = User.find_by_login("admin")
        else
          authorization_method = if controller.request.authorization =~ /^OAuth/
                                   :oauth
                                 else
                                   :http_basic
                                 end
          User.current         ||= send(authorization_method) || (return false)
        end

        return true
      end

      def authorize
        User.current.allowed_to?(
            :controller => controller.params[:controller].gsub(/::/, "_").underscore,
            :action     => controller.params[:action])
      end

      def http_basic
        controller.authenticate_with_http_basic do |u, p|
          @user_login = u
          User.try_to_login(u, p)
        end
      end

      def oauth
        unless Setting['oauth_active'] &&
            (OAuth::RequestProxy.proxy(controller.request).oauth_consumer_key == Setting['consumer_key'])
          return nil
        end

        if OAuth::Signature.verify(controller.request, :consumer_secret => Setting['consumer_secret'])
          # TODO find user by header
          return User.find_by_login("admin")
        else
          return nil
        end
      end
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
      finder, key = case
                      when (id = params[:"#{resource_name}_id"]).present?
                        ['id', id]
                      when (name = params[:"#{resource_name}_name"]).present?
                        ['name', name]
                      else
                        [nil, nil]
                    end

      resource = resource_class.send(:"find_by_#{finder}", key) if finder

      if resource
        return instance_variable_set(:"@#{resource_name}", resource)
      else
        render_error 'not_found', :status => :not_found, :locals => { :finder => finder, :key => key } and
            return false
      end
    end

    def set_default_response_format
      request.format = :json if params[:format].nil?
    end

    # store params[:id] under correct predicable key
    def set_resource_params
      if (id_or_name = params.delete(:id))
        suffix                                = (id_or_name.is_a?(Fixnum) || id_or_name =~ /^\d+$/) ? 'id' : 'name'
        params[:"#{resource_name}_#{suffix}"] = id_or_name
      end
    end

    def api_version
      raise NotImplementedError
    end

    def render_error(error, options = { })
      render options.merge(:template => "/api/v#{api_version}/errors/#{error}")
    end
  end
end
