module Api
  module V1
    class ComputeResourcesController < V1::BaseController
      before_filter :find_resource, :only => :show

      api :GET, "/compute_resources/", "List all compute resources."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @compute_resources = ComputeResource.my_compute_resources.search_for(params[:search], :order => params[:order])

      end

      api :GET, "/compute_resources/:id/", "Show an compute resource."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
