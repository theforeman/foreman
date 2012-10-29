module Api
  module V1
    class AuditsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/audits/", "List all audits."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @audits = Audit.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/audits/:id/", "Show an audit."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
