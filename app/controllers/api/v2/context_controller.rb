module Api
  module V2
    class ContextController < V2::BaseController

      api :GET, "/context", N_("Get the application context")
      param :only, Array, N_("Array of keys to return")

      def index
        metadata = helpers.app_metadata

        if (only = params[:only])
          if !only.is_a?(Array)
            render_error :custom_error, :status => :unprocessable_entity,
                         :locals => { :message => _("Parameter \"only\" has to be of type array.") }
          else
            sliced = metadata.slice(*only.map { |x| x.to_sym })
            render json: { metadata: sliced }
          end
        else render json: { metadata: metadata }
        end
      end
    end
  end
end
