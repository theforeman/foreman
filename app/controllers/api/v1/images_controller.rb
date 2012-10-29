module Api
  module V1
    class ImagesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_compute_resource

      api :GET, "/images/", "List all images."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @images = @compute_resource.images.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/images/:id/", "Show an image."
      param :id, :identifier, :required => true
      def show
      end

      private

      def find_compute_resource
        @compute_resource = ComputeResource.find(params[:compute_resource_id])
      end

    end
  end
end
