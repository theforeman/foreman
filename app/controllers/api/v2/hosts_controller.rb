module Api
  module V2
    class HostsController < V2::BaseController
      include Api::Version2
      include ScopesPerAction
      include Foreman::Controller::SmartProxyAuth
      include Foreman::Controller::Parameters::Host
      include ParameterAttributes

      wrap_parameters :host, :include => host_params_filter.accessible_attributes(parameter_filter_context) + ['compute_attributes']
      include HostsControllerExtension

      before_action :find_optional_nested_object, :except => [:facts]
      before_action :find_resource, :except => [:index, :create, :facts]
      check_permissions_for %w{power boot}
      before_action :process_parameter_attributes, :only => %w{update}

      add_smart_proxy_filters :facts, :features => proc { Foreman::Plugin.fact_importer_registry.fact_features }

      add_scope_for(:index) do |base_scope|
        base_scope.preload([:host_statuses, :compute_resource, :hostgroup, :operatingsystem,
                            :interfaces, :token, :owner, :model, :environment, :location,
                            :organization, :image, :compute_profile, :realm, :architecture,
                            :ptable, :medium, :puppet_proxy, :puppet_ca_proxy])
      end

      api :GET, "/hosts/", N_("List all hosts")
      api :GET, "/hostgroups/:hostgroup_id/hosts", N_("List all hosts for a host group")
      api :GET, "/locations/:location_id/hosts", N_("List hosts per location")
      api :GET, "/organizations/:organization_id/hosts", N_("List hosts per organization")
      api :GET, "/environments/:environment_id/hosts", N_("List hosts per environment")
      param :thin, :bool, :desc => N_("Only list ID and name of hosts")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :environment_id, String, :desc => N_("ID of environment")
      param :include, ['parameters', 'all_parameters'], :desc => N_("Array of extra information types to include")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Host)

      def index
        @hosts = action_scope_for(:index, resource_scope_for_index)

        if params[:thin]
          @subtotal = @hosts.total_entries
          @hosts = @hosts.reorder(:name).distinct.pluck(:id, :name)
          render 'thin'
          return
        end

        # SQL optimizations queries
        @last_report_ids = Report.where(:host_id => @hosts.map(&:id)).group(:host_id).maximum(:id)
        @last_reports = Report.where(:id => @last_report_ids.values)
        if params[:include].present?
          @parameters = params[:include].include?('parameters')
          @all_parameters = params[:include].include?('all_parameters')
        end
      end

      api :GET, "/hosts/:id/", N_("Show a host")
      param :id, :identifier_dottable, :required => true
      param :show_hidden_parameters, :bool, :desc => N_("Display hidden parameter values")

      def show
        @parameters = true
        @all_parameters = true
      end

      def_param_group :host do
        param :host, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :location_id, :number, :required => true
          param :organization_id, :number, :required => true
          param :environment_id, String, :desc => N_("required if host is managed and value is not inherited from host group")
          param :ip, String, :desc => N_("not required if using a subnet with DHCP proxy")
          param :mac, String, :desc => N_("required for managed host that is bare metal, not required if it's a virtual machine")
          param :architecture_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :domain_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :realm_id, :number
          Host.registered_smart_proxies.each do |name, options|
            param :"#{name}_id", :number, :desc => options[:api_description]
          end
          param :puppetclass_ids, Array
          param :config_group_ids, Array, :desc => N_("IDs of associated config groups")
          param :operatingsystem_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :medium_id, String, :desc => N_("required if not imaged based provisioning and host is managed and value is not inherited from host group")
          param :pxe_loader, Operatingsystem.all_loaders, :desc => N_("DHCP filename option (Grub2/PXELinux by default)")
          param :ptable_id, :number, :desc => N_("required if host is managed and custom partition has not been defined")
          param :subnet_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :compute_resource_id, :number, :desc => N_("nil means host is bare metal")
          param :root_pass, String, :desc => N_("required if host is managed and value is not inherited from host group or default password in settings")
          param :model_id, :number
          param :hostgroup_id, :number
          param :owner_id, :number
          param :owner_type, Host::Base::OWNER_TYPES, :desc => N_("Host's owner type"),  :required => true
          param :image_id, :number
          param :host_parameters_attributes, Array, :desc => N_("Host's parameters (array or indexed hash)") do
            param :name, String, :desc => N_("Name of the parameter"), :required => true
            param :value, String, :desc => N_("Parameter value"), :required => true
            param :parameter_type, Parameter::KEY_TYPES, :desc => N_("Type of value")
            param :hidden_value, :bool
          end
          param :build, :bool
          param :enabled, :bool, :desc => N_("Include this host within Foreman reporting")
          param :provision_method, Host::Managed.provision_methods.keys, :desc => N_("The method used to provision the host.")
          param :managed, :bool, :desc => N_("True/False flag whether a host is managed or unmanaged. Note: this value also determines whether several parameters are required or not")
          param :progress_report_id, String, :desc => N_("UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks")
          param :comment, String, :desc => N_("Additional information about this host")
          param :capabilities, String
          param :compute_profile_id, :number
          param :interfaces_attributes, Array, :desc => N_("Host's network interfaces.") do
            param :id, :number, :desc => N_("ID of interface")
            param_group :interface_attributes, ::Api::V2::InterfacesController
          end
          param :compute_attributes, Hash, :desc => N_("Additional compute resource specific attributes.")

          Facets.registered_facets.values.each do |facet_config|
            next unless facet_config.host_configuration.api_param_group && facet_config.host_configuration.api_controller
            param "#{facet_config.name}_attributes".to_sym, Hash, :desc => facet_config.api_param_group_description || (N_("Parameters for host's %s facet") % facet_config.name) do
              facet_config.host_configuration.load_api_controller
              param_group facet_config.host_configuration.api_param_group, facet_config.host_configuration.api_controller
            end
          end
        end
      end

      api :POST, "/hosts/", N_("Create a host")
      param_group :host, :as => :create

      def create
        @parameters = true
        @all_parameters = true

        if params[:host][:uuid].present? && params[:host][:compute_resource_id].present?
          @host = import_host
          @host.assign_attributes(host_attributes(host_params))
        else
          @host = Host.new(host_attributes(host_params))
          @host.managed = true if (params[:host] && params[:host][:managed].nil?)
        end
        apply_compute_profile(@host)
        @host.suggest_default_pxe_loader if params[:host] && params[:host][:pxe_loader].nil?

        forward_request_url
        process_response @host.save
      rescue InterfaceTypeMapper::UnknownTypeException => e
        render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => e.to_s }
      end

      api :PUT, "/hosts/:id/", N_("Update a host")
      param :id, :identifier, :required => true
      param_group :host

      def update
        @parameters = true
        @all_parameters = true

        @host.attributes = host_attributes(host_params, @host)
        apply_compute_profile(@host) if (params[:host] && params[:host][:compute_attributes].present?) || @host.compute_profile_id_changed?

        process_response @host.save
      rescue InterfaceTypeMapper::UnknownTypeException => e
        render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => e.to_s }
      end

      api :DELETE, "/hosts/:id/", N_("Delete a host")
      param :id, :identifier, :required => true

      def destroy
        process_response @host.destroy
      end

      api :GET, "/hosts/:id/enc", N_("Get ENC values of host")
      param :id, :identifier_dottable, :required => true

      def enc
        render :json => { :data => @host.info }
      end

      api :GET, "/hosts/:id/status/:type", N_("Get status of host")
      param :id, :identifier_dottable, :required => true
      param :type, [HostStatus::Global] + HostStatus.status_registry.to_a.map { |s| s.humanized_name }, :required => true, :desc => N_(
        <<~EOS
          status type, can be one of
          * global
          * configuration
          * build
        EOS
      )

      description N_('Returns string representing a host status of a given type')
      def get_status
        case params[:type]
          when 'global'
            @status = @host.build_global_status
          else
            @status = @host.get_status(HostStatus.find_status_by_humanized_name(params[:type]))
        end
      end

      api :DELETE, "/hosts/:id/status/:type", N_("Clear sub-status of host")
      param :id, :identifier_dottable, :required => true
      param :type, HostStatus.status_registry.to_a.map { |s| s.humanized_name }, :required => true, :desc => N_(
        <<~EOS
          status type
        EOS
      )

      description N_('Clears a host sub-status of a given type')
      def forget_status
        status = @host.get_status(HostStatus.find_status_by_humanized_name(params[:type]))
        if params[:type] == 'global'
          render :json => { :error => _("Cannot delete global status.") }, :status => :unprocessable_entity
        elsif status.type.empty? || status.id.nil?
          render :json => { :error => _("Status %s does not exist.") % params[:type] }, :status => :unprocessable_entity
        else
          process_response status.delete
        end
      end

      api :GET, "/hosts/:id/vm_compute_attributes", N_("Get vm attributes of host")
      param :id, :identifier_dottable, :required => true
      description <<~EOS
        Return the host's compute attributes that can be used to create a clone of this VM
      EOS

      def vm_compute_attributes
        render :json => {} unless @host
        attrs = @host.vm_compute_attributes || {}
        safe_attrs = {}
        attrs.each_pair do |k, v|
          # clean up the compute attributes to be suitable for output
          if v.is_a?(Proc)
            safe_attrs[k] = v.call
          elsif v.respond_to?('parent')
            # don't add folders, causes recursive json issues
          else
            safe_attrs[k] = v
          end
        end
        render :json => safe_attrs
      end

      api :PUT, "/hosts/:id/disassociate", N_("Disassociate the host from a VM")
      param :id, :identifier_dottable, :required => true
      def disassociate
        @host.disassociate!
        render 'api/v2/hosts/show'
      end

      api :PUT, "/hosts/:id/power", N_("Run a power operation on host")
      param :id, :identifier_dottable, :required => true
      param :power_action, String, :required => true, :desc => N_("power action, valid actions are (on/start), (off/stop), (soft/reboot), (cycle/reset), (state/status)")

      def power
        unless @host.supports_power?
          return render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => _('Power operations are not enabled on this host.') }
        end

        valid_actions = PowerManager::SUPPORTED_ACTIONS
        if valid_actions.include? params[:power_action]
          render :json => { :power => @host.power.send(params[:power_action]) }, :status => :ok
        else
          render :json => { :error => _("Unknown power action: available methods are %s") % valid_actions.join(', ') }, :status => :unprocessable_entity
        end
      end

      api :GET, '/hosts/:id/power', N_('Fetch the status of whether the host is powered on or not. Supported hosts are VMs and physical hosts with BMCs.')
      param :id, :identifier_dottable, required: true

      def power_status
        render json: PowerManager::PowerStatus.new(host: @host).power_state
      rescue => e
        Foreman::Logging.exception("Failed to fetch power status", e)

        resp = {
          id: @host.id,
          statusText: _("Failed to fetch power status: %s") % e,
        }

        render json: resp.merge(PowerManager::PowerStatus::HOST_POWER[:na])
      end

      api :PUT, "/hosts/:id/boot", N_("Boot host from specified device")
      param :id, :identifier_dottable, :required => true
      param :device, String, :required => true, :desc => N_("boot device, valid devices are disk, cdrom, pxe, bios")

      def boot
        valid_devices = ProxyAPI::BMC::SUPPORTED_BOOT_DEVICES
        if valid_devices.include? params[:device]
          render :json => { :boot => @host.ipmi_boot(params[:device]) }, :status => :ok
        else
          render :json => { :error => _("Unknown device: available devices are %s") % valid_devices.join(', ') }, :status => :unprocessable_entity
        end
      rescue ::Foreman::Exception => e
        render_exception(e, :status => :unprocessable_entity)
      end

      api :POST, "/hosts/facts", N_("Upload facts for a host, creating the host if required")
      param :name, String, :required => true, :desc => N_("hostname of the host")
      param :facts, Hash,      :required => true, :desc => N_("hash containing the facts for the host")
      param :certname, String, :desc => N_("optional: certname of the host")
      param :type, String,     :desc => N_("optional: the STI type of host to create")

      def facts
        @host = detect_host_type.import_host params[:name], params[:certname]
        state = HostFactImporter.new(@host).import_facts(params[:facts].to_unsafe_h, detected_proxy)
        process_response state
      rescue ::Foreman::Exception => e
        render_exception(e, :status => :unprocessable_entity)
      end

      api :PUT, "/hosts/:id/rebuild_config", N_("Rebuild orchestration config")
      param :id, :identifier_dottable, :required => true
      param :only, Array, :desc => N_("Limit rebuild steps, valid steps are %{host_rebuild_steps}")
      def rebuild_config
        result = @host.recreate_config(params[:only])
        failures = result.reject { |key, value| value }.keys.map { |k| _(k) }
        if failures.empty?
          render_message _("Configuration successfully rebuilt."), :status => :ok
        else
          render_message (_("Configuration rebuild failed for: %s.") % failures.to_sentence), :status => :unprocessable_entity
        end
      end

      api :GET, "/hosts/:id/template/:kind", N_("Preview rendered provisioning template content")
      param :id, :identifier_dottable, :required => true
      param :kind, String, :required => true, :desc => N_("Template kinds, available values: %{template_kinds}")
      def template
        template = @host.provisioning_template({ :kind => params[:kind] })
        if template.nil?
          not_found(_("No template with kind %{kind} for %{host}") % {:kind => params[:kind], :host => @host.to_label})
        else
          render :json => { :template => @host.render_template(template: template) }, :status => :ok
        end
      end

      private

      def apply_compute_profile(host)
        host.apply_compute_profile(InterfaceMerge.new(:merge_compute_attributes => true))
        host.apply_compute_profile(ComputeAttributeMerge.new)
      end

      def host_attributes(params, host = nil)
        return {} if params.nil?

        params = params.deep_clone
        if params[:interfaces_attributes]
          # handle both hash and array styles of nested attributes
          if params[:interfaces_attributes].is_a?(Hash) || params[:interfaces_attributes].is_a?(ActionController::Parameters)
            params[:interfaces_attributes] = params[:interfaces_attributes].values
          end
          # map interface types
          params[:interfaces_attributes] = params[:interfaces_attributes].map do |nic_attr|
            interface_attributes(nic_attr, allow_nil_type: host.nil?)
          end
        end
        params = host.apply_inherited_attributes(params) if host
        params
      end

      def interface_attributes(params, allow_nil_type: false)
        params[:type] = InterfaceTypeMapper.map(params[:type]) if params.has_key?(:type) || allow_nil_type
        params
      end

      def action_permission
        case params[:action]
          when 'power_status'
            :power
          when 'power'
            :power
          when 'boot'
            :ipmi_boot
          when 'console'
            :console
          when 'disassociate', 'forget_status'
            :edit
          when 'vm_compute_attributes', 'get_status', 'template', 'enc'
            :view
          when 'rebuild_config'
            :build
          else
            super
        end
      end

      def parent_permission(child_permission)
        case child_permission.to_s
          when 'power', 'boot', 'console', 'vm_compute_attributes', 'get_status', 'template', 'enc', 'rebuild_config'
            'view'
          when 'disassociate'
            'edit'
          else
            super
        end
      end

      # this is required for template generation (such as pxelinux) which is not done via a web request
      def forward_request_url
        @host.request_url = request.host_with_port if @host.respond_to?(:request_url)
      end

      def detect_host_type
        return Host::Managed if params[:type].blank?
        if params[:type].constantize.new.is_a?(Host::Base)
          logger.debug "Creating host of type: #{params[:type]}"
          params[:type].constantize
        else
          raise ::Foreman::Exception.new(N_("Invalid type for host creation via facts: %s"), params[:type])
        end
      rescue => e
        raise ::Foreman::Exception.new(N_("A problem occurred when detecting host type: %s"), e.message)
      end

      def permissions_check
        permission = "#{action_permission}_hosts".to_sym
        deny_access unless Host.authorized(permission, Host).find(@host.id)
      end

      def resource_class
        Host::Managed
      end

      def allowed_nested_id
        %w(hostgroup_id location_id organization_id environment_id)
      end

      def resource_class_join(association, scope)
        resource_class_join = resource_class.joins(association.name)
        if action_name == 'update' && resource_class_join.merge(scope).blank?
          resource_class_join
        else
          resource_class.joins(association.name).merge(scope)
        end
      end

      def import_host
        compute_resource = ComputeResource.authorized(:edit_compute_resources).find(params[:host][:compute_resource_id])
        ComputeResourceHostImporter.new(
          :compute_resource => compute_resource,
          :uuid => params[:host][:uuid]
        ).host
      end
    end
  end
end
