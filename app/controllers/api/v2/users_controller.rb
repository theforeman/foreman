module Api
  module V2
    class UsersController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/users/index"
      end

      def show
        super
        render :template => "api/v1/users/show"
      end

    end
  end
end
