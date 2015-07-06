module Api
  module V1
    class ReportsController < V1::BaseController
      before_filter :deprecated
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => [:index, :last]

      api :GET, "/reports/", "List all reports."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @reports = ConfigReport.
          authorized(:view_config_reports).
          my_reports.
          includes(:logs => [:source, :message]).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/reports/:id/", "Show a report."
      param :id, :identifier, :required => true

      def show
      end

      api :DELETE, "/reports/:id/", "Delete a report."
      param :id, String, :required => true

      def destroy
        process_response @report.destroy
      end

      api :GET, "/hosts/:host_id/reports/last", "Show the last report for a given host."
      param :id, :identifier, :required => true

      def last
        conditions = { :host_id => Host.find(params[:host_id]).try(:id) } unless params[:host_id].blank?
        max_id = ConfigReport.authorized(:view_config_reports).my_reports.where(conditions).maximum(:id)
        @report = ConfigReport.authorized(:view_config_reports).includes(:logs => [:message, :source]).find(max_id)
        render :show
      end

      private

      def deprecated
        Foreman::Deprecation.api_deprecation_warning("Reports were renamed to ConfigReports")
      end
    end
  end
end
