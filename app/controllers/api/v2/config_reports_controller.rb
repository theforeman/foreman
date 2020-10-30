module Api
  module V2
    class ConfigReportsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      # wrapping is extremely slow for large JSON reports, make sure it's not used for this endpoint
      wrap_parameters :format => []

      before_action :find_resource, :only => %w{destroy}
      before_action :setup_search_options, :only => [:index, :last]
      before_action :compatibility, :only => :create

      add_smart_proxy_filters :create, :features => proc { ConfigReportImporter.authorized_smart_proxy_features }

      api :GET, "/config_reports/", N_("List all reports")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ConfigReport)

      def index
        @config_reports = resource_scope_for_index.my_reports
        @total = ConfigReport.my_reports.count
      end

      api :GET, "/config_reports/:id/", N_("Show a report")
      param :id, :identifier, :required => true

      def show
        @config_report = resource_scope.includes(:logs => [:message, :source]).find(params[:id])
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
        @config_report = ConfigReport.import(params.to_unsafe_h[:config_report], detected_proxy.try(:id))
        process_response @config_report.errors.empty?
      rescue ::Foreman::Exception => e
        render_exception(e, :status => :unprocessable_entity)
      end

      api :DELETE, "/config_reports/:id/", N_("Delete a report")
      param :id, String, :required => true

      def destroy
        process_response @config_report.destroy
      end

      api :GET, "/hosts/:host_id/config_reports/last", N_("Show the last report for a host")
      param :id, :identifier, :required => true

      def last
        if params[:host_id].present?
          conditions = { :host_id => resource_finder(Host.authorized(:view_hosts), params[:host_id]).try(:id) }
        end
        max_id = resource_scope.where(conditions).maximum(:id)
        @config_report = resource_scope.includes(:logs => [:message, :source]).find(max_id)
        render :show
      end

      private

      def setup_search_options
        params[:search] ||= ""
        params[:search] += " host = " + params[:host_id] if params[:host_id]
      end

      def resource_scope(options = {})
        options[:permission] = :view_config_reports
        super(options).my_reports
      end

      def action_permission
        case params[:action]
          when 'last'
            'view'
          else
            super
        end
      end

      # This is needed for backwards compatibility with Ansible and Chef report callbacks
      def compatibility
        return unless params[:report].present?
        Foreman::Deprecation.api_deprecation_warning("The report parameter was renamed to config_reports and the API endpoint has changed from /reports to /config_reports. Please use the new API.")
        params[:config_report] = params.delete(:report)
      end
    end
  end
end
