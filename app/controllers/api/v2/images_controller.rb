module Api
  module V2
    class ImagesController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :find_compute_resource

      api :GET, "/compute_resources/:compute_resource_id/images/", N_("List all images for a compute resource")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")
      param :compute_resource_id, :identifier, :required => true

      def index
        base = @compute_resource.images.authorized(:view_images)
        @images = base.search_for(*search_options).paginate(paginate_options)
        @total = base.count
      end

      api :GET, "/compute_resources/:compute_resource_id/images/:id/", N_("Show an image")
      param :id, :identifier, :required => true
      param :compute_resource_id, :identifier, :required => true

      def show
      end

      def_param_group :image do
        param :image, Hash, :action_aware => true do
          param :name, String, :required => true
          param :username, String, :required => true
          param :uuid, String, :required => true
          param :compute_resource_id, :number, :required => true
          param :architecture_id, :number, :required => true
          param :operatingsystem_id, :number, :required => true
        end
      end

      api :POST, "/compute_resources/:compute_resource_id/images/", N_("Create an image")
      param :compute_resource_id, :identifier, :required => true
      param_group :image, :as => :create

      def create
        @image = @compute_resource.images.new(params[:image])
        process_response @image.save, @compute_resource
      end

      api :PUT, "/compute_resources/:compute_resource_id/images/:id/", N_("Update an image")
      param :compute_resource_id, :identifier, :required => true
      param :id, :identifier, :required => true
      param_group :image

      def update
        process_response @image.update_attributes(params[:image])
      end

      api :DELETE, "/compute_resources/:compute_resource_id/images/:id/", N_("Delete an image")
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
