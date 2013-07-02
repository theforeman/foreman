module Api
  module V2
    class HostgroupsController < V1::HostgroupsController

      include Api::Version2
      include Api::TaxonomyScope

      def index
        super
        render :template => "api/v1/hostgroups/index"
      end

      def show
        super
        render :template => "api/v1/hostgroups/show"
      end

    end
  end
end
