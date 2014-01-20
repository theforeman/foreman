module Api
  module V2
    class AuditsController < V2::BaseController
      before_filter :find_resource, :only => %w{show}
      before_filter(:only => %w{show}) { find_resource('audit_logs') }
      before_filter :setup_search_options, :only => :index

      api :GET, "/audits/", "List all audits."
      api :GET, "/hosts/:host_id/audits/", "List all audits for a given host."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        Audit.unscoped { @audits = Audit.authorized(:view_audit_logs).search_for(*search_options).paginate(paginate_options) }
      end

      api :GET, "/audits/:id/", "Show an audit"
      param :id, :identifier, :required => true

      def show
      end

    end
  end
end
