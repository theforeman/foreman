module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base

    before_filter :set_default_response_format

    def process_error hash = {}
      hash[:object] ||= get_resource || raise("Param 'object' was not defined")

      hash[:json_code] ||= :unprocessable_entity
      
      errors = if hash[:object].respond_to?(:errors)
        logger.info "Failed to save: #{hash[:object].errors.full_messages.join(", ")}" 
        hash[:object].errors.full_messages
      else
        raise("Object has to respond to errors")
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


    def request_from_katello_cli?
       request.headers['User-Agent'].to_s =~ /^katello-cli/
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
