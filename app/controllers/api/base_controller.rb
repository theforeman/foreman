module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base

    before_filter :set_default_response_format, :authorize, :set_resource_params

    respond_to :json

    def process_error(options = { })
      options[:json_code] ||= :unprocessable_entity

      errors = if options[:error]
                 options[:error]
               else
                 options[:object] ||= get_resource || raise("No error to process")
                 if options[:object].respond_to?(:errors)
                   #TODO JSON resposne should include the real errors, not the pretty full messages
                   logger.info "Failed to save: #{options[:object].errors.full_messages.join(", ")}"
                   options[:object].errors.full_messages
                 else
                   raise("No error to process")
                 end
               end

      # set 403 status on permission errors
      if errors.any? { |error| error =~ /You do not have permission/ }
        options[:json_code] = :forbidden
      end

      render :json => { "errors" => errors }, :status => options[:json_code]
    end


    def process_response(condition, response = nil)
      if condition
        response ||= get_resource
        respond_with response
      else
        process_error
      end
    end

    # Authorize the user for the requested action
    def authorize(ctrl = params[:controller], action = params[:action])

      if SETTINGS[:login]
        unless User.current
          user_to_login = nil
          if result = authenticate_with_http_basic { |u, p| user_to_login = u; User.try_to_login(u, p) }
            User.current = result
          else
            process_error :error => "Unable to authenticate user %s" % user_to_login, :json_code => :unauthorized
            return false
          end
        end
      else
        # We assume we always have a user logged in, if authentication is disabled, the user is the build-in admin account.
        User.current = User.find_by_login("admin")
      end

      User.current.allowed_to?(:controller => ctrl.gsub(/::/, "_").underscore, :action => action) or deny_access
    end

    def deny_access
      process_error :error => "Access denied", :json_code => :forbidden
      false
    end

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
    # searches for a resource based on its name and assign it to an instance variable
    # required for models which implement the to_param method
    #
    # example:
    # @host = Host.find_resource params[:id]
    def find_resource
      finder, key = case
                      when (id = params[:"#{resource_name}_id"]).present?
                        [:find_by_id, id]
                      when (name = params[:"#{resource_name}_name"]).present?
                        [:find_by_name, name]
                      else
                        [nil, nil]
                    end
      resource = resource_class.send(finder, key) if finder

      if finder && resource
        return instance_variable_set(:"@#{resource_name}", resource)
      else
        not_found and return false
      end
    end

    def not_found(exception = nil)
      logger.debug "not found: #{exception}" if exception
      head :status => 404
    end

    def set_default_response_format
      request.format = :json if params[:format].nil?
    end

    # store params[:id] under correct predicable key
    def set_resource_params
      if (id_or_name = params.delete(:id))
        suffix                                = id_or_name =~ /^\d+$/ ? 'id' : 'name'
        params[:"#{resource_name}_#{suffix}"] = id_or_name
      end
    end

  end
end
