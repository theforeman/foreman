module Api
  class ApiResponder < ActionController::Responder

    # overview api_behavior
    def api_behavior(error)
      raise error unless resourceful?

      if !get? && !post?
      	#return resource instead of default :no_contentfor PUT and DELETE
      	display resource
      else
        super
      end

    end
  end
end
