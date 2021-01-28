module Api
  module V2
    class HostgroupClassesController < V2::BaseController
      include Api::V2::ExtractedPuppetController

      api :GET, "/hostgroups/:hostgroup_id/puppetclass_ids/", N_("List all Puppet class IDs for host group")
      def index
      end

      api :POST, "/hostgroups/:hostgroup_id/puppetclass_ids", N_("Add a Puppet class to host group")
      def create
      end

      api :DELETE, "/hostgroups/:hostgroup_id/puppetclass_ids/:id/", N_("Remove a Puppet class from host group")
      def destroy
      end
    end
  end
end
