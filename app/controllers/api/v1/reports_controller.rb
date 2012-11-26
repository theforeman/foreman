module Api
  module V1
    class ReportsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => [:index, :last]

      api :GET, "/reports/", "List all reports."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @reports = Report.my_reports.includes(:logs => [:source, :message]).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/reports/:id/", "Show a report."
      param :id, :identifier, :required => true

      def show
      end

      api :DELETE, "/ptables/:id/", "Delete a report."
      param :id, String, :required => true

      def destroy
        process_response @report.destroy
      end

      def last
        #default order is reported_at desc
        @reports = Report.my_reports.includes(:logs => [:source, :message]).
          search_for(*search_options).paginate(paginate_options)
        # last (most recent report) is first in list
        @report = @reports.first
        # if params[:host_id].blank?
        #    @report = Report.my_reports.includes(:logs => [:source, :message]).last
        # else 
        #    @reports = Report.my_reports.includes(:logs => [:source, :message]).search_for(*search_options)
           
        # end
        render :show
      end

    end
  end
end
