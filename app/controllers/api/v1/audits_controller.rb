module Api
  module V1
    class AuditsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => :index

      api :GET, "/audits/", "List all audits."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        Audit.unscoped { @audits = Audit.search_for(*search_options).paginate(paginate_options) }
      end

      api :GET, "/audits/:id/", "Show an audit"
      param :id, :identifier, :required => true

      def show
      end

    end
  end
end
