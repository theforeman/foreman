module Api
  module V2
    class EnvironmentsController < V1::EnvironmentsController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/environments/index"
      end

      def show
        super
        render :template => "api/v1/environments/show"
      end

    end
  end
end
