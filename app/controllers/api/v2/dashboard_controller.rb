module Api
  module V2
    class DashboardController < V2::BaseController
      param :search, String, :desc => N_("filter results"), :required => false
      api :GET, "/dashboard/", N_("Get dashboard details")

      def index
        status = Dashboard::Data.status(params[:search])
        respond_to do |format|
          format.yaml { render :text => status.to_yaml }
          format.json { render :json => status }
        end
      end
    end
  end
end
