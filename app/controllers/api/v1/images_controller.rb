module Api
  module V1
    class ImagesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_compute_resource

      api :GET, "/compute_resources/:id/images/", "List all images for compute resource."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      param :page,  String, :desc => "paginate results"
      def index
        @images = @compute_resource.images.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/compute_resources/:id/images/:id/", "Show an image."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/compute_resources/:id/images/", "Create a image."
      param :image, Hash, :required => true do
        param :name, String, :required => true
        param :username, String, :required => true
        param :uuid, String, :required => true
        param :compute_resource_id, :number, :required => true
        param :architecture_id, :number, :required => true
        param :operatingsystem_id, :number, :required => true
      end
      def create
        @image =  @compute_resource.images.new(params[:image])
        process_response @image.save, @compute_resource
      end

      api :PUT, "/images/:id/", "Update a image."
      param :id, :identifier, :required => true
      param :image, Hash, :required => true do
        param :name, String, :required => true
        param :username, String, :required => true
        param :uuid, String, :required => true
        param :compute_resource_id, :number, :required => true
        param :architecture_id, :number, :required => true
        param :operatingsystem_id, :number, :required => true
      end
      def update
        process_response @image.update_attributes(params[:image])
      end

      api :DELETE, "/images/:id/", "Delete an image."
      param :id, :identifier, :required => true
      def destroy
        process_response @image.destroy
      end

      private

      def find_compute_resource
        @compute_resource = ComputeResource.find(params[:compute_resource_id])
      end

    end
  end
end
