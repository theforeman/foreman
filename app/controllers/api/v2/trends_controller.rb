module Api
  module V2
    class TrendsController < V2::BaseController
      include Foreman::Controller::Parameters::Trend

      before_action :ensure_statistics_plugin
      before_action :find_resource, :only => [:show, :destroy]

      TRENDABLE_TYPES = [
        'Environment', 'Operatingsystem', 'Model', 'FactName', 'Hostgroup',
        'ComputeResource'
      ].freeze

      api :GET, "/trends/", N_("List of trends counters")
      def index
        Foreman::Deprecation.api_deprecation_warning("use /foreman_statistics/trends endpoind from Foreman Statistics plugin instead")
        @trends = resource_scope_for_index
      end

      api :GET, "/trends/:id/", N_("Show a trend")
      param :id, :identifier, :required => true
      def show
        Foreman::Deprecation.api_deprecation_warning("use /foreman_statistics/trends/:id endpoind from Foreman Statistics plugin instead")
      end

      api :POST, "/trends/", N_("Create a trend counter")
      param :trendable_type, TRENDABLE_TYPES, :required => true
      param :fact_name, String, :required => false
      param :name, String, :required => false
      def create
        Foreman::Deprecation.api_deprecation_warning("use /foreman_statistics/trends endpoind from Foreman Statistics plugin instead")
        @trend = ForemanStatistics::Trend.build_trend(trend_params)
        if @trend.save
          process_success
        else
          process_resource_error
        end
      end

      api :DELETE, "/trends/:id/", N_("Delete a trend counter")
      param :id, :identifier, :required => true
      def destroy
        Foreman::Deprecation.api_deprecation_warning("use /foreman_statistics/trends/:id endpoind from Foreman Statistics plugin instead")
        process_response @trend.destroy
      end

      # Overload this method to avoid using search_for method
      def resource_scope_for_index(options = {})
        resource_scope(options).paginate(paginate_options)
      end

      def resource_scope(options = {})
        @resource_scope ||= scope_for(ForemanStatistics::Trend.types, options)
      end

      def ensure_statistics_plugin
        plugin = Foreman::Plugin.find(:foreman_statistics)
        not_found(_('For access to /trends API you need to install Foreman Statistics plugin')) if plugin.nil?
      end
    end
  end
end
