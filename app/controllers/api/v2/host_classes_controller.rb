module Api
  module V2
    class HostClassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_host_id, :only => [:index, :create, :destroy]

      api :GET, "/hosts/:host_id/puppetclass_ids/", N_("List all Puppet class IDs for host")

      def index
        render :json => { root_node_name => HostClass.authorized(:edit_classes).where(:host_id => host_id).pluck('puppetclass_id') }
      end

      api :POST, "/hosts/:host_id/puppetclass_ids", N_("Add a Puppet class to host")
      param :host_id, String, :required => true, :desc => N_("ID of host")
      param :puppetclass_id, String, :required => true, :desc => N_("ID of puppetclass")

      def create
        @host_class = HostClass.create!(:host_id => host_id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:host_id => @host_class.host_id, :puppetclass_id => @host_class.puppetclass_id}
      end

      api :DELETE, "/hosts/:host_id/puppetclass_ids/:id/", N_("Remove a Puppet class from host")
      param :host_id, String, :required => true, :desc => N_("ID of host")
      param :id, String, :required => true, :desc => N_("ID of Puppet class")

      def destroy
        @host_class = HostClass.authorized(:edit_classes).where(:host_id => host_id, :puppetclass_id => params[:id])
        process_response @host_class.destroy_all
      end

      private
      attr_reader :host_id

      def find_host_id
        if params[:host_id] =~ /^\d+$/
          return @host_id = params[:host_id].to_i
        else
          @host ||= Host::Managed.authorized(:view_hosts).find_by_name(params[:host_id])
          return @host_id = @host.id if @host
          not_found
        end
      end

    end
  end
end
