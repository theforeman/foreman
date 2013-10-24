module Api
  module V2
    class ComputeResourcesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => [:available_images]

      def index
        super
        render :template => "api/v1/compute_resources/index"
      end

      def show
        super
        render :template => "api/v1/compute_resources/show"
      end

      api :GET, "/compute_resources/:id/available_images/", "List available images for a compute resource."
      param :id, :identifier, :required => true
      def available_images
        @available_images = @compute_resource.available_images
      end

    end
  end
end
