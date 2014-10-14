module Api
  module V2
    class HostgroupsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy clone}

      api :GET, "/hostgroups/", N_("List all host groups")
      api :GET, "/puppetclasses/:puppetclass_id/hostgroups", N_("List all host groups for a Puppet class")
      api :GET, "/locations/:location_id/hostgroups", N_("List all host groups per location")
      api :GET, "/organizations/:organization_id/hostgroups", N_("List all host groups per organization")
      param :puppetclass_id, String, :desc => N_("ID of Puppet class")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @hostgroups = resource_scope_for_index
      end

      api :GET, "/hostgroups/:id/", N_("Show a host group")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :hostgroup do
        param :hostgroup, Hash, :required => true, :action_aware => true do
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
          param_group :taxonomies, ::Api::V2::BaseController
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
          render :json => {'message'=> _("Cannot delete group %{current} because it has nested host groups.") % { :current => @hostgroup.title } }, :status => :conflict
        else
          process_response @hostgroup.destroy
        end
      end

      api :POST, "/hostgroups/:id/clone", N_("Clone a host group")
      param :name, String, :required => true

      def clone
        @hostgroup = @hostgroup.clone(params[:name])
        process_response @hostgroup.save
      end

      api :POST, "/hostgroups/:hostgroup_id/links/locations", N_("Add location to host group")
      api :POST, "/hostgroups/:hostgroup_id/links/organizations", N_("Add organization to host group")
      api :POST, "/hosts/:host_id/links/puppetclasses", N_("Add puppetclass to host")
      api :POST, "/hosts/:host_id/links/config_groups", N_("Add config group to host")
      param :hostgroup_id, :identifier, :required => true
      param_group :taxonomies_associations, ::Api::V2::BaseController
      param :puppetclasses, Array, :required => false, :desc => N_("Array of puppetclass IDs")
      param :config_groups, Array, :required => false, :desc => N_("Array of config group IDs")
      def add
      end

      api :DELETE, "/hostgroups/:hostgroup_id/links/locations/:id", N_("Remove location from host group")
      api :DELETE, "/hostgroups/:hostgroup_id/links/organizations/:id", N_("Remove organization from host group")
      api :DELETE, "/hosts/:host_id/links/puppetclasses/:id", N_("Remove puppetclass from host")
      api :DELETE, "/hosts/:host_id/links/config_groups/:id", N_("Remove config group from host")
      param :hostgroup_id, :identifier, :required => true
      param :id, String, :required => true, :desc => N_("ID or comma-delimited list of IDs")
      def remove
      end

      private

      def action_permission
        case params[:action]
          when 'clone'
            'create'
          else
            super
        end
      end

      def allowed_nested_id
        %w(puppetclass_id location_id organization_id)
      end

    end
  end
end
