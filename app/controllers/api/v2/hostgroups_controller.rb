module Api
  module V2
    class HostgroupsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Hostgroup
      include ParameterAttributes

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone rebuild_config}
      before_action :process_parameter_attributes, :only => %w{update}
      before_action :include_parameters_in_response, :only => %w{show create update}

      api :GET, "/hostgroups/", N_("List all host groups")
      api :GET, "/puppetclasses/:puppetclass_id/hostgroups", N_("List all host groups for a Puppet class")
      api :GET, "/locations/:location_id/hostgroups", N_("List all host groups per location")
      api :GET, "/organizations/:organization_id/hostgroups", N_("List all host groups per organization")
      param :puppetclass_id, String, :desc => N_("ID of Puppet class")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      param :include, Array, :in => ['parameters'], :desc => N_("Array of extra information types to include")
      add_scoped_search_description_for(Hostgroup)

      def index
        @hostgroups = resource_scope_for_index

        if params[:include].present?
          @parameters = params[:include].include?('parameters')
        end
      end

      api :GET, "/hostgroups/:id/", N_("Show a host group")
      param :id, :identifier, :required => true
      param :show_hidden_parameters, :bool, :desc => N_("Display hidden parameter values")

      def show
      end

      def_param_group :hostgroup do
        param :hostgroup, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_('Name of the host group')
          param :description, String, :desc => N_('Host group description')
          param :parent_id, :number, :desc => N_('Parent ID of the host group')
          param :compute_profile_id, :number, :desc => N_('Compute profile ID')
          param :compute_resource_id, :number, :desc => N_('Compute resource ID')
          param :operatingsystem_id, :number, :desc => N_('Operating system ID')
          param :architecture_id, :number, :desc => N_('Architecture ID')
          param :pxe_loader, Operatingsystem.all_loaders, :desc => N_("DHCP filename option (Grub2/PXELinux by default)")
          param :medium_id, :number, :desc => N_('Media ID')
          param :ptable_id, :number, :desc => N_('Partition table ID')
          param :subnet_id, :number, :desc => N_('Subnet ID')
          param :subnet6_id, :number, :desc => N_('Subnet IPv6 ID')
          param :domain_id, :number, :desc => N_('Domain ID')
          param :realm_id, :number, :desc => N_('Realm ID')
          param :puppetclass_ids, Array
          param :config_group_ids, Array, :desc => N_("IDs of associated config groups")
          param :group_parameters_attributes, Array, :required => false, :desc => N_("Array of parameters") do
            param :name, String, :desc => N_("Name of the parameter"), :required => true
            param :value, String, :desc => N_("Parameter value"), :required => true
            param :parameter_type, Parameter::KEY_TYPES, :desc => N_("Type of value")
            param :hidden_value, :bool
          end
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
        process_response @hostgroup.update(hostgroup_params)
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

      api :PUT, "/hostgroups/:id/rebuild_config", N_("Rebuild orchestration config")
      param :id, :identifier, :required => true
      param :only, Array, :desc => N_("Limit rebuild steps, valid steps are %{host_rebuild_steps}")
      param :children_hosts, :bool, :desc => N_("Operate on child hostgroup hosts")
      def rebuild_config
        results = @hostgroup.recreate_hosts_config(params[:only], params[:children_hosts])
        failures = []
        results.each_pair do |host, result|
          host_failures = result.reject { |key, value| value }.keys.map { |k| _(k) }
          failures << "#{host}(#{host_failures.to_sentence})" unless host_failures.empty?
        end
        if failures.empty?
          render_message _("Configuration successfully rebuilt."), :status => :ok
        else
          render_error :custom_error, :status => :unprocessable_entity,
                       :locals => { :message => _("Configuration rebuild failed for: %s." % failures.to_sentence) }
        end
      end

      private

      def include_parameters_in_response
        @parameters = true
      end

      def action_permission
        case params[:action]
          when 'clone'
            'create'
          when 'rebuild_config'
            :edit
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
