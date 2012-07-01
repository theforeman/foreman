module Api
  module V1

    class DashboardController  < BaseController
      include Foreman::Controller::AutoCompleteSearch

      param :search, String, :desc => "filter results", :required => false
      api :GET, "/dashboard/", "Get Dashboard results"
      def index
        @report = Dashboard.data(params[:search])
        respond_to do |format|
          format.yaml { render :text => @report.to_yaml }
          format.json { render :json => @report.to_json }
        end

      end


    end
  end
end
