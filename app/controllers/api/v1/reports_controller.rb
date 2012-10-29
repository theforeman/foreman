module Api
  module V1
    class ReportsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/reports/", "List all reports."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @reports = Report.my_reports.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/reports/:id/", "Show a report."
      param :id, :identifier, :required => true
      def show
      end

      def summaryStatus
        return "Failed"   if error?
        return "Modified" if changes?
        return "Success"
      end

    end
  end
end
