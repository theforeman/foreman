module Api
  module V2
    class DomainsController < V1::DomainsController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/domains/index"
      end

      def show
        super
        render :template => "api/v1/domains/show"
      end

    end
  end
end
