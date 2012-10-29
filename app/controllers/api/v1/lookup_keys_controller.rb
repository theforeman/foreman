module Api
  module V1
    class LookupKeysController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/lookup_keys/", "List all lookup_keys."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @lookup_keys = LookupKey.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/lookup_keys/:id/", "Show an lookup key."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
