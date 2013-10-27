module Api
  module V2
    class ReportsController < V1::ReportsController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      add_puppetmaster_filters :create

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

    end
  end
end
