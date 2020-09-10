module Api
  module V2
    class AuditsController < V2::BaseController
      before_action :find_resource, :only => %w{show}

      api :GET, "/audits/", N_("List all audits")
      api :GET, "/hosts/:host_id/audits/", N_("List all audits for a given host")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Audit)

      def index
        Audit.unscoped { @audits = resource_scope_for_index(:permission => :view_audit_logs) }
      end

      api :GET, "/audits/:id/", N_("Show an audit")
      param :id, :identifier, :required => true

      def show
      end

      def resource_base(*args)
        super(*args).taxed_and_untaxed
      end
    end
  end
end
