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

      api :GET, "/systems/:system_id/reports/last", "Show the last report for a given system."
      param :id, :identifier, :required => true

      def last
        conditions = { :system_id => System.find_by_name(params[:system_id]).try(:id) } unless params[:system_id].blank?
        max_id = Report.my_reports.where(conditions).maximum(:id)
        @report = Report.includes(:logs => [:message, :source]).find(max_id)
        render :show
      end

    end
  end
end
