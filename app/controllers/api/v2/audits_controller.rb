module Api
  module V2
    class AuditsController < V2::BaseController
      before_filter :find_resource, :only => %w{show}
      before_filter :setup_search_options, :only => :index

      api :GET, "/audits/", N_("List all audits")
      api :GET, "/hosts/:host_id/audits/", N_("List all audits for a given host")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        Audit.unscoped { @audits = resource_scope_for_index(:permission => :view_audit_logs) }
      end

      api :GET, "/audits/:id/", N_("Show an audit")
      param :id, :identifier, :required => true

      def show
      end

    end
  end
end
