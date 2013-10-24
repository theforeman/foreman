module Api
  module V2
    class SmartProxiesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/smart_proxies/index"
      end

      def show
        super
        render :template => "api/v1/smart_proxies/show"
      end

    end
  end
end
