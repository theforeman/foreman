module Api
  module V2
    class SubnetsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/subnets/index"
      end

      def show
        super
        render :template => "api/v1/subnets/show"
      end

    end
  end
end
