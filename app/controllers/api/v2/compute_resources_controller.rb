module Api
  module V2
    class ComputeResourcesController < V1::ComputeResourcesController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/compute_resources/index"
      end

      def show
        super
        render :template => "api/v1/compute_resources/show"
      end

    end
  end
end
