module Api
  module V2
    class HostgroupClassesController < V2::BaseController
      include Api::Version2

      before_action :find_hostgroup, :only => [:index, :create, :destroy]

      api :GET, "/hostgroups/:hostgroup_id/puppetclass_ids/", N_("List all Puppet class IDs for host group")

      def index
        render :json => { root_node_name => HostgroupClass.where(:hostgroup_id => @hostgroup.id).pluck('puppetclass_id') }
      end

      api :POST, "/hostgroups/:hostgroup_id/puppetclass_ids", N_("Add a Puppet class to host group")
      param :hostgroup_id, String, :required => true, :desc => N_("ID of host group")
      param :puppetclass_id, String, :required => true, :desc => N_("ID of Puppet class")

      def create
        @hostgroup_class = HostgroupClass.create!(:hostgroup_id => @hostgroup.id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:hostgroup_id => @hostgroup_class.hostgroup_id, :puppetclass_id => @hostgroup_class.puppetclass_id}
      end

      api :DELETE, "/hostgroups/:hostgroup_id/puppetclass_ids/:id/", N_("Remove a Puppet class from host group")
      param :hostgroup_id, String, :required => true, :desc => N_("ID of host group")
      param :id, String, :required => true, :desc => N_("ID of Puppet class")

      def destroy
        @hostgroup_class = HostgroupClass.where(:hostgroup_id => @hostgroup.id, :puppetclass_id => params[:id])
        process_response @hostgroup_class.destroy_all
      end

      private

      def find_hostgroup
        if params[:hostgroup_id].blank?
          not_found
          return false
        end
        @hostgroup = Hostgroup.find(params[:hostgroup_id]) if Hostgroup.respond_to?(:authorized) &&
                                                              Hostgroup.authorized("view_hostgroup", Hostgroup)
      end
    end
  end
end
