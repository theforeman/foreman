module Api
  module V2
    class MediaController < V1::MediaController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/media/index"
      end

      def show
        super
        render :template => "api/v1/media/show"
      end

    end
  end
end
