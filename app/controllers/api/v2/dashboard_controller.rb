module Api
  module V2
    class DashboardController < V2::BaseController
      param :search, String, :desc => N_("filter results"), :required => false
      api :GET, "/dashboard/", N_("Get dashboard details")

      def index
        status = Dashboard::Data.status(params[:search])
        respond_to do |format|
          format.yaml { render :plain => status.to_yaml }
          format.json { render :json => status.merge(glossary) }
        end
      end

      private

      def glossary
        {
          :glossary => {
            :total_hosts               => _('Total hosts count'),
            :bad_hosts                 => _('Hosts with error state'),
            :bad_hosts_enabled         => _('Hosts with error state and alerts enabled'),
            :active_hosts              => _('Hosts which recently applied changes'),
            :active_hosts_ok           => _('Hosts which recently applied changes successfully'),
            :active_hosts_ok_enabled   => _('Hosts which recently applied changes successfully with alerts enabled'),
            :ok_hosts                  => _('Hosts without changes or errors'),
            :ok_hosts_enabled          => _('Hosts without changes or errors, with alerts enabled'),
            :out_of_sync_hosts         => _('Out of sync hosts'),
            :out_of_sync_hosts_enabled => _('Out of sync hosts with alerts enabled'),
            :disabled_hosts            => _('Hosts with alerts disabled'),
            :pending_hosts             => _('Hosts that had pending changes'),
            :pending_hosts_enabled     => _('Hosts that had pending changes with alerts enabled'),
            :good_hosts                => _('Hosts without errors'),
            :good_hosts_enabled        => _('Hosts without errors, with alerts enabled'),
            :percentage                => _('Hosts without errors percent'),
            :reports_missing           => _('Hosts which are not reporting'),
          },
        }
      end
    end
  end
end
