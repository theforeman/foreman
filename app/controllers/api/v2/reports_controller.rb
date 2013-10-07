module Api
  module V2
    class ReportsController < V1::ReportsController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      add_puppetmaster_filters [:create, :report_deprecation_msg]

      api :POST, "/reports/", "Create a report."
      param :report, Hash, :required => true do
        param :host, String, :required => true, :desc => "Hostname or certname"
        param :reported_at, String, :required => true, :desc => "UTC time of report"
        param :status, Hash, :required => true, :desc => "Hash of status type totals"
        param :metrics, Hash, :required => true, :desc => "Hash of report metrics, can be just {}"
        param :logs, Array, :desc => "Optional array of log hashes"
      end

      def create
        @report = Report.import(params[:report])
        process_response @report.valid?
      rescue ::Foreman::Exception => e
        render :json => {'message'=>e.to_s}, :status => :unprocessable_entity
      end

      def report_deprecation_msg
        msg  = "/reports/create is deprecated, update your report processor to POST to /api/reports\n"
        msg += '  See the Foreman 1.3 release notes for a new example report processor'
        logger.error "DEPRECATION: #{msg}."
        render :json => {:message => msg}, :status => 400
      end

    end
  end
end
