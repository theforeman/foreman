module Api
  module V1

    class DashboardController < V1::BaseController

      param :search, String, :desc => "filter results", :required => false
      api :GET, "/dashboard/", "Get Dashboard results"

      def index
        status = Dashboard.status(params[:search])
        respond_to do |format|
          format.yaml { render :text => status.to_yaml }
          format.json { render :json => status }
        end
      end

    end

  end
end
