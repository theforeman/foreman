module Api
  module V2
    class ConfigReportsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => [:index, :last]

      add_smart_proxy_filters :create, :features => ConfigReportImporter.authorized_smart_proxy_features

      api :GET, "/config_reports/", N_("List all reports")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @config_reports = resource_scope_for_index.my_reports.includes(:logs => [:source, :message])
        @total = ConfigReport.my_reports.count
      end

      api :GET, "/config_reports/:id/", N_("Show a report")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :config_report do
        param :config_report, Hash, :required => true, :action_aware => true do
          param :host, String, :required => true, :desc => N_("Hostname or certname")
          param :reported_at, String, :required => true, :desc => N_("UTC time of report")
          param :status, Hash, :required => true, :desc => N_("Hash of status type totals")
          param :metrics, Hash, :required => true, :desc => N_("Hash of report metrics, can be just {}")
          param :logs, Array, :desc => N_("Optional array of log hashes")
        end
      end

      api :POST, "/config_reports/", N_("Create a report")
      param_group :config_report, :as => :create

      def create
        @config_report = ConfigReport.import(params[:config_report], detected_proxy.try(:id))
        process_response @config_report.errors.empty?
      rescue ::Foreman::Exception => e
        render_message(e.to_s, :status => :unprocessable_entity)
      end

      api :DELETE, "/config_reports/:id/", N_("Delete a report")
      param :id, String, :required => true

      def destroy
        process_response @config_report.destroy
      end

      api :GET, "/hosts/:host_id/config_reports/last", N_("Show the last report for a host")
      param :id, :identifier, :required => true

      def last
        conditions = { :host_id => Host.find(params[:host_id]).id } unless params[:host_id].blank?
        max_id = ConfigReport.authorized(:view_config_reports).my_reports.where(conditions).maximum(:id)
        @config_report = ConfigReport.authorized(:view_config_reports).includes(:logs => [:message, :source]).find(max_id)
        render :show
      end
    end
  end
end
