module Api
  module V1
    include DashboardHelper

    class DashboardController  < BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :prefetch_data, :only => :index

      api :GET, "/dashboard/", "Get Dashboard results"
      def index
        respond_to do |format|
          format.yaml { render :text => @report.to_yaml }
          format.json { render :json => @report }
        end

      end


    end
  end
end
