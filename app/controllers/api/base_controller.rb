module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base

    before_filter :set_default_response_format
    before_filter :authorize
    
    def process_error hash = {}
      
      hash[:json_code] ||= :unprocessable_entity
      
      errors = if hash[:error]
        hash[:error]
      else
        hash[:object] ||= get_resource || raise("No error to process")
        if hash[:object].respond_to?(:errors)
          logger.info "Failed to save: #{hash[:object].errors.full_messages.join(", ")}" 
          hash[:object].errors.full_messages
        else
          raise("No error to process")
        end
      end

      render :json => {"errors" => errors} , :status => hash[:json_code]
    end

    def get_resource 
      instance_variable_get(:"@#{controller_name.singularize}")
    end


    def process_response condition, response = nil
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
            process_error({:error => "Unable to authenticate user %s" % user_to_login, :json_code => :unauthorized})
            return false
          end
        end
      else
        # We assume we always have a user logged in, if authentication is disabled, the user is the build-in admin account.
        User.current = User.find_by_login("admin")
      end

      allowed = User.current.allowed_to?({:controller => ctrl.gsub(/::/, "_").underscore, :action => action})
      allowed ? true : deny_access
    end

    def deny_access
      process_error({:error => "Access denied", :json_code => :unauthorized})
      return false
    end


    protected
    # searches for an object based on its name and assign it to an instance variable
    # required for models which implement the to_param method
    #
    # example:
    # @host = Host.find_by_name params[:id]
    def find_by_name
      not_found and return if (id = params[:id]).blank?

      obj = controller_name.singularize
      # determine if we are searching for a numerical id or plain name
      cond = "find_by_" + ((id =~ /^\d+$/ && (id=id.to_i)) ? "id" : "name")
      not_found and return unless eval("@#{obj} = #{obj.camelize}.#{cond}(id)")
    end

    def not_found(exception = nil)
      logger.debug "not found: #{exception}" if exception
      head :status => 404
    end

    def set_default_response_format
      request.format = :json if params[:format].nil?
    end

  end
end
