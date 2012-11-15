module Api
  module V1
    class ComputeResourcesController < V1::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

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

      api :POST, "/compute_resources/", "Create a compute resource."
      param :compute_resource, Hash, :required => true do
        param :name, String, :required => true
        param :provider, String, :required => true
        param :url, String, :required => true
      end
      def create
        @compute_resource = ComputeResource.new(params[:compute_resource])
        process_response @compute_resource.save
      end

      api :PUT, "/compute_resources/:id/", "Update a compute resource."
      param :id, String, :required => true
      param :compute_resource, Hash, :required => true do
        param :name, String, :allow_nil => true
        param :provider, String, :allow_nil => true
        param :url, String, :allow_nil => true
      end
      def update
        process_response @compute_resource.update_attributes(params[:compute_resource])
      end

      api :DELETE, "/compute_resources/:id/", "Delete a compute resource."
      param :id, String, :required => true
      def destroy
        process_response @compute_resource.destroy
      end

    end
  end
end
