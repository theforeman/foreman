module Api
  module V2
    class PuppetclassesController < V2::BaseController
      include Api::V2::ExtractedPuppetController

      api :GET, "/puppetclasses/", N_("List all Puppet classes")
      api :GET, "/hosts/:host_id/puppetclasses", N_("List all Puppet classes for a host")
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses", N_("List all Puppet classes for a host group")
      api :GET, "/environments/:environment_id/puppetclasses", N_("List all Puppet classes for an environment")
      def index
      end

      api :GET, "/puppetclasses/:id", N_("Show a Puppet class")
      api :GET, "/hosts/:host_id/puppetclasses/:id", N_("Show a Puppet class for host")
      api :GET, "/hostgroups/:hostgroup_id/puppetclasses/:id", N_("Show a Puppet class for a host group")
      api :GET, "/environments/:environment_id/puppetclasses/:id", N_("Show a Puppet class for an environment")
      def show
      end

      def_param_group :puppetclass do
        param :puppetclass, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/puppetclasses/", N_("Create a Puppet class")
      param_group :puppetclass, :as => :create
      def create
      end

      api :PUT, "/puppetclasses/:id/", N_("Update a Puppet class")
      param :id, String, :required => true
      param_group :puppetclass
      def update
      end

      api :DELETE, "/puppetclasses/:id/", N_("Delete a Puppet class")
      param :id, String, :required => true
      def destroy
      end
    end
  end
end
