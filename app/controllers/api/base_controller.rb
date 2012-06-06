module Api
  #TODO: inherit from application controller after cleanup
  class BaseController < ActionController::Base

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

  end
end
