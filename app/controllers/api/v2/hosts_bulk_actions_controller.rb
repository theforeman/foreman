module Api
  module V2
    class HostsBulkActionsController < V2::BaseController
      include Api::Version2
      include Api::V2::BulkHostsExtension

      before_action :find_deletable_hosts, :only => [:bulk_destroy]

      def_param_group :bulk_host_ids do
        param :organization_id, :number, :required => true, :desc => N_("ID of the organization")
        param :included, Hash, :desc => N_("Hosts to include in the action"), :required => true, :action_aware => true do
          param :search, String, :required => false, :desc => N_("Search string describing which hosts to perform the action on")
          param :ids, Array, :required => false, :desc => N_("List of host ids to perform the action on")
        end
        param :excluded, Hash, :desc => N_("Hosts to explicitly exclude in the action."\
                                           " All other hosts will be included in the action,"\
                                           " unless an included parameter is passed as well."), :required => true, :action_aware => true do
          param :ids, Array, :required => false, :desc => N_("List of host ids to exclude and not perform the action on")
        end
      end

      api :DELETE, "/hosts/bulk/", N_("Delete multiple hosts")
      param_group :bulk_host_ids
      def bulk_destroy
        process_response @hosts.destroy_all
      end

      private

      def find_deletable_hosts
        find_bulk_hosts(:destroy_hosts, params)
      end
    end
  end
end
