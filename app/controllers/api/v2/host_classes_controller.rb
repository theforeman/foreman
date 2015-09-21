module Api
  module V2
    class HostClassesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_host, :only => [:index, :create, :destroy]

      api :GET, "/hosts/:host_id/puppetclass_ids/", N_("List all Puppet class IDs for host")

      def index
        render :json => { root_node_name => HostClass.authorized(:edit_classes).where(:host_id => @host.id).pluck('puppetclass_id') }
      end

      api :POST, "/hosts/:host_id/puppetclass_ids", N_("Add a Puppet class to host")
      param :host_id, String, :required => true, :desc => N_("ID of host")
      param :puppetclass_id, String, :required => true, :desc => N_("ID of Puppet class")

      def create
        @host_class = HostClass.create!(:host_id => @host.id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:host_id => @host_class.host_id, :puppetclass_id => @host_class.puppetclass_id}
      end

      api :DELETE, "/hosts/:host_id/puppetclass_ids/:id/", N_("Remove a Puppet class from host")
      param :host_id, String, :required => true, :desc => N_("ID of host")
      param :id, String, :required => true, :desc => N_("ID of Puppet class")

      def destroy
        @host_class = HostClass.authorized(:edit_classes).where(:host_id => @host.id, :puppetclass_id => params[:id])
        process_response @host_class.destroy_all
      end

      private

      # overwrite resource_name so it's host and and not host_class, since we want to return @host
      def find_host
        not_found and return false if params[:host_id].blank?
        @host = Host.friendly.find(params[:host_id]) if Host::Managed.respond_to?(:authorized) &&
                                               Host::Managed.authorized("view_host", Host::Managed)
      end
    end
  end
end
