module Api
  module V2
    class TrendsController < V2::BaseController
      # include Api::Version2
      include Foreman::Controller::Parameters::Trend

      before_action :find_resource, :only => [:show, :destroy]

      api :GET, "/trends/", N_("List of trends counters")
      def index
        @trends = resource_scope_for_index.trend_source
      end


      api :GET, "/trends/:id/", N_("Show a trend")
      param :trend_id, :identifier, :required => true
      def show
      end

      api :POST, "/trends/", N_("Create a trend counter")
      def create
        params[:trend] ||= { }
        @trend  = params[:trend][:trendable_type] == 'FactName' ? FactTrend.new(trend_params) : ForemanTrend.new(trend_params)
        if @trend.save
          process_success
        else
          process_error
        end
      end

      api :DELETE, "/trends/:id/", N_("Delete a trend counter")
      param :id, :identifier, :required => true
      def destroy
        process_response @trend.destroy
      end

      def find_resource
        # super(:scope => resource_scope_for_index.trend_source )
        instance_variable_set("@#{resource_name}", resource_finder(resource_scope_for_index.trend_source, params[:id]))
      end
    end
  end
end
