module Api
  module V2
    class HostgroupsController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Foreman::Controller::Parameters::Hostgroup

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone}

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
          param :name, String, :required => true, :desc => N_('Name of the host group')
          param :parent_id, :number, :desc => N_('Parent ID of the host group')
          param :environment_id, :number, :desc => N_('Environment ID')
          param :compute_profile_id, :number, :desc => N_('Compute profile ID')
          param :operatingsystem_id, :number, :desc => N_('Operating system ID')
          param :architecture_id, :number, :desc => N_('Architecture ID')
          param :pxe_loader, Operatingsystem.all_loaders, :desc => N_("DHCP filename option (Grub2/PXELinux by default)")
          param :medium_id, :number, :desc => N_('Media ID')
          param :ptable_id, :number, :desc => N_('Partition table ID')
          param :subnet_id, :number, :desc => N_('Subnet ID')
          param :domain_id, :number, :desc => N_('Domain ID')
          param :realm_id, :number, :desc => N_('Realm ID')
          param :config_group_ids, Array, :desc => N_("IDs of associated config groups")
          Hostgroup.registered_smart_proxies.each do |name, options|
            param :"#{name}_id", :number, :desc => options[:api_description]
          end
          param :root_pass, String, :desc => N_('Root password on provisioned hosts')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/hostgroups/", N_("Create a host group")
      param_group :hostgroup, :as => :create

      def create
        @hostgroup = Hostgroup.new(hostgroup_params)
        @hostgroup.suggest_default_pxe_loader if params[:hostgroup] && params[:hostgroup][:pxe_loader].nil?

        process_response @hostgroup.save
      end

      api :PUT, "/hostgroups/:id/", N_("Update a host group")
      param :id, :identifier, :required => true
      param_group :hostgroup

      def update
        process_response @hostgroup.update_attributes(hostgroup_params)
      end

      api :DELETE, "/hostgroups/:id/", N_("Delete a host group")
      param :id, :identifier, :required => true

      def destroy
        if @hostgroup.has_children?
          render_message(_("Cannot delete group %{current} because it has nested host groups.") % { :current => @hostgroup.title }, :status => :conflict)
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
