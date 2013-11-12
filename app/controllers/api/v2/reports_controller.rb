module Api
  module V2
    class ReportsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => [:index, :last]
      add_puppetmaster_filters :create

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

      api :POST, "/reports/", "Create a report."
      param :report, Hash, :required => true do
        param :host, String, :required => true, :desc => "Hostname or certname"
        param :reported_at, String, :required => true, :desc => "UTC time of report"
        param :status, Hash, :required => true, :desc => "Hash of status type totals"
        param :metrics, Hash, :required => true, :desc => "Hash of report metrics, can be just {}"
        param :logs, Array, :desc => "Optional array of log hashes"
      end

      def create
        @report = Report.import(params[:report], detected_proxy.try(:id))
        process_response @report.errors.empty?
      rescue ::Foreman::Exception => e
        render :json => {'message'=>e.to_s}, :status => :unprocessable_entity
      end

      api :DELETE, "/ptables/:id/", "Delete a report."
      param :id, String, :required => true

      def destroy
        process_response @report.destroy
      end

      api :GET, "/hosts/:host_id/reports/last", "Show the last report for a given host."
      param :id, :identifier, :required => true

      def last
        conditions = { :host_id => Host.find_by_name(params[:host_id]).try(:id) } unless params[:host_id].blank?
        max_id = Report.my_reports.where(conditions).maximum(:id)
        @report = Report.includes(:logs => [:message, :source]).find(max_id)
        render :show
      end

    end
  end
end
