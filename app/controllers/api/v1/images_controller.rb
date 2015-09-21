module Api
  module V1
    class ImagesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_compute_resource

      api :GET, "/compute_resources/:compute_resource_id/images/", "List all images for compute resource"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"
      param :compute_resource_id, :identifier, :required => true

      def index
        @images = @compute_resource.
          images.
          authorized(:view_images).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/compute_resources/:compute_resource_id/images/:id/", "Show an image"
      param :id, :identifier, :required => true
      param :compute_resource_id, :identifier, :required => true

      def show
      end

      api :POST, "/compute_resources/:compute_resource_id/images/", "Create a image"
      param :compute_resource_id, :identifier, :required => true
      param :image, Hash, :required => true do
        param :name, String, :required => true
        param :username, String, :required => true
        param :uuid, String, :required => true
        param :compute_resource_id, :number, :required => true
        param :architecture_id, :number, :required => true
        param :operatingsystem_id, :number, :required => true
      end

      def create
        @image = @compute_resource.images.new(foreman_params)
        process_response @image.save, @compute_resource
      end

      api :PUT, "/compute_resources/:compute_resource_id/images/:id/", "Update a image."
      param :compute_resource_id, :identifier, :required => true
      param :id, :identifier, :required => true
      param :image, Hash, :required => true do
        param :name, String
        param :username, String
        param :uuid, String
        param :compute_resource_id, :number
        param :architecture_id, :number
        param :operatingsystem_id, :number
      end

      def update
        process_response @image.update_attributes(foreman_params)
      end

      api :DELETE, "/compute_resources/:compute_resource_id/images/:id/", "Delete an image."
      param :compute_resource_id, :identifier, :required => true
      param :id, :identifier, :required => true

      def destroy
        process_response @image.destroy
      end

      private

      def find_compute_resource
        @compute_resource = ComputeResource.authorized(:view_compute_resources).find(params[:compute_resource_id])
      end
    end
  end
end
