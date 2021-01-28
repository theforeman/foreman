module Api
  module V2
    class HostClassesController < V2::BaseController
      include Api::V2::ExtractedPuppetController

      api :GET, "/hosts/:host_id/puppetclass_ids/", N_("List all Puppet class IDs for host")
      def index
      end

      api :POST, "/hosts/:host_id/puppetclass_ids", N_("Add a Puppet class to host")
      def create
      end

      api :DELETE, "/hosts/:host_id/puppetclass_ids/:id/", N_("Remove a Puppet class from host")
      def destroy
      end
    end
  end
end
