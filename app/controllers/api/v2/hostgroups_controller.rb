module Api
  module V2
    class HostgroupsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/hostgroups/", N_("List all host groups")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @hostgroups = Hostgroup.
          authorized(:view_hostgroups).
          includes(:hostgroup_classes, :group_parameters).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/hostgroups/:id/", N_("Show a host group")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :hostgroup do
        param :hostgroup, Hash, :action_aware => true do
          param :name, String, :required => true
          param :parent_id, :number
          param :environment_id, :number
          param :operatingsystem_id, :number
          param :architecture_id, :number
          param :medium_id, :number
          param :ptable_id, :number
          param :puppet_ca_proxy_id, :number
          param :subnet_id, :number
          param :domain_id, :number
          param :realm_id, :number
          param :puppet_proxy_id, :number
        end
      end

      api :POST, "/hostgroups/", N_("Create a host group")
      param_group :hostgroup, :as => :create

      def create
        @hostgroup = Hostgroup.new(params[:hostgroup])
        process_response @hostgroup.save
      end

      api :PUT, "/hostgroups/:id/", N_("Update a host group")
      param :id, :identifier, :required => true
      param_group :hostgroup

      def update
        process_response @hostgroup.update_attributes(params[:hostgroup])
      end

      api :DELETE, "/hostgroups/:id/", N_("Delete a host group")
      param :id, :identifier, :required => true

      def destroy
        if @hostgroup.has_children?
          render :json => {'message'=> _("Cannot delete group %{current} because it has nested groups.") % { :current => @hostgroup.title } }, :status => :conflict
        else
          process_response @hostgroup.destroy
        end
      end

    end
  end
end
