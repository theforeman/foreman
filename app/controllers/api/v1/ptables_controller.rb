module Api
  module V1
    class PtablesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/ptables/", "List all ptables."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @ptables = Ptable.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/ptables/:id/", "Show a ptable."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
