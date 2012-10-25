module Api
  module V1
    class CommonParametersController < V1::BaseController
      before_filter :find_resource, :only => :show

      api :GET, "/common_parameters/", "List all common parameters."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @common_parameters = CommonParameter.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/common_parameters/:id/", "Show a common parameter."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
