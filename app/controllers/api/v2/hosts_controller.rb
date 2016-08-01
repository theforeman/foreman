module Api
  module V2
    class HostsController < V2::BaseController
      include Api::Version2
      include Api::CompatibilityChecker
      include Api::TaxonomyScope
      include Foreman::Controller::SmartProxyAuth
      include Foreman::Controller::Parameters::Host

      wrap_parameters :host, :include => host_params_filter.accessible_attributes(parameter_filter_context) + ['compute_attributes']

      before_action :check_create_host_nested, :only => [:create, :update]

      before_action :find_optional_nested_object, :except => [:facts]
      before_action :find_resource, :except => [:index, :create, :facts]
      before_action :permissions_check, :only => %w{power boot puppetrun}

      add_smart_proxy_filters :facts, :features => Proc.new { FactImporter.fact_features }

      api :GET, "/hosts/", N_("List all hosts")
      api :GET, "/hostgroups/:hostgroup_id/hosts", N_("List all hosts for a host group")
      api :GET, "/locations/:location_id/hosts", N_("List hosts per location")
      api :GET, "/organizations/:organization_id/hosts", N_("List hosts per organization")
      api :GET, "/environments/:environment_id/hosts", N_("List hosts per environment")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :environment_id, String, :desc => N_("ID of environment")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @hosts = resource_scope_for_index.includes([ :host_statuses, :compute_resource, :hostgroup, :operatingsystem, :interfaces, :token ])
        # SQL optimizations queries
        @last_report_ids = Report.where(:host_id => @hosts.map(&:id)).group(:host_id).maximum(:id)
        @last_reports = Report.where(:id => @last_report_ids.values)
      end

      api :GET, "/hosts/:id/", N_("Show a host")
      param :id, :identifier_dottable, :required => true

      def show
      end

      def_param_group :host do
        param :host, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :location_id, :number, :required => true, :desc => N_("required if locations are enabled") if SETTINGS[:locations_enabled]
          param :organization_id, :number, :required => true, :desc => N_("required if organizations are enabled") if SETTINGS[:organizations_enabled]
          param :environment_id, String, :desc => N_("required if host is managed and value is not inherited from host group")
          param :ip, String, :desc => N_("not required if using a subnet with DHCP proxy")
          param :mac, String, :desc => N_("required for managed host that is bare metal, not required if it's a virtual machine")
          param :architecture_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :domain_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :realm_id, :number
          param :puppet_proxy_id, :number
          param :puppetclass_ids, Array
          param :operatingsystem_id, String, :desc => N_("required if host is managed and value is not inherited from host group")
          param :medium_id, String, :desc => N_("required if not imaged based provisioning and host is managed and value is not inherited from host group")
          param :ptable_id, :number, :desc => N_("required if host is managed and custom partition has not been defined")
          param :subnet_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :compute_resource_id, :number, :desc => N_("nil means host is bare metal")
          param :root_pass, String, :desc => N_("required if host is managed and value is not inherited from host group or default password in settings")
          param :model_id, :number
          param :hostgroup_id, :number
          param :owner_id, :number
          param :owner_type, Host::Base::OWNER_TYPES, :desc => N_("Host's owner type")
          param :puppet_ca_proxy_id, :number
          param :image_id, :number
          param :host_parameters_attributes, Array, :desc => N_("Host's parameters (array or indexed hash)") do
            param :name, String, :desc => N_("Name of the parameter"), :required => true
            param :value, String, :desc => N_("Parameter value"), :required => true
          end
          param :build, :bool
          param :enabled, :bool
          param :provision_method, String, :desc => N_("The method used to provision the host. Possible provision_methods may be %{provision_methods}") # values are defined in apipie initializer
          param :managed, :bool, :desc => N_("True/False flag whether a host is managed or unmanaged. Note: this value also determines whether several parameters are required or not")
          param :progress_report_id, String, :desc => N_("UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks")
          param :comment, String, :desc => N_("Additional information about this host")
          param :capabilities, String
          param :compute_profile_id, :number
          param :interfaces_attributes, Array, :desc => N_("Host's network interfaces.") do
            param_group :interface_attributes, ::Api::V2::InterfacesController
          end
          param :compute_attributes, Hash, :desc => N_("Additional compute resource specific attributes.")

          Facets.registered_facets.values.each do |facet_config|
            next unless facet_config.api_param_group && facet_config.api_controller
            param "#{facet_config.name}_attributes".to_sym, Hash, :desc => facet_config.api_param_group_description || (N_("Parameters for host's %s facet") % facet_config.name) do
              param_group facet_config.api_param_group, facet_config.api_controller
            end
          end
        end
      end

      api :POST, "/hosts/", N_("Create a host")
      param_group :host, :as => :create

      def create
        @host = Host.new(host_attributes(host_params))
        @host.managed = true if (params[:host] && params[:host][:managed].nil?)
        apply_compute_profile(@host)

        forward_request_url
        process_response @host.save
      rescue InterfaceTypeMapper::UnknownTypeExeption => e
        render_error :custom_error, :status => :unprocessable_entity, :locals => { :message => e.to_s }
      end

      api :PUT, "/hosts/:id/", N_("Update a host")
      param :id, :identifier, :required => true
      param_group :host

      def update
        @host.attributes = host_attributes(host_params, @host)
        apply_compute_profile(@host)

        process_response @host.save
      rescue InterfaceTypeMapper::UnknownTypeExeption => e
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

      api :GET, "/hosts/:id/status", N_("Get configuration status of host")
      param :id, :identifier_dottable, :required => true
      description <<-eos
Return value may either be one of the following:

* missing
* failed
* pending
* changed
* unchanged
* unreported
      eos

      def status
        Foreman::Deprecation.api_deprecation_warning('The /status route is deprecated, please use the new /status/configuration instead')
        render :json => { :status => @host.get_status(HostStatus::ConfigurationStatus).to_label }.to_json if @host
      end

      api :GET, "/hosts/:id/status/:type", N_("Get status of host")
      param :id, :identifier_dottable, :required => true
      param :type, [ HostStatus::Global ] + HostStatus.status_registry.to_a.map { |s| s.humanized_name }, :required => true, :desc => N_(<<-eos
status type, can be one of
* global
* configuration
* build
eos
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

      api :GET, "/hosts/:id/vm_compute_attributes", N_("Get vm attributes of host")
      param :id, :identifier_dottable, :required => true
      description <<-eos
Return the host's compute attributes that can be used to create a clone of this VM
      eos

      def vm_compute_attributes
        render :json => {} unless @host
        attrs = @host.vm_compute_attributes || {}
        safe_attrs = {}
        attrs.each_pair do |k,v|
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

      api :PUT, "/hosts/:id/puppetrun", N_("Force a Puppet agent run on the host")
      param :id, :identifier_dottable, :required => true

      def puppetrun
        return deny_access unless Setting[:puppetrun]
        process_response @host.puppetrun!
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
        valid_actions = PowerManager::SUPPORTED_ACTIONS
        if valid_actions.include? params[:power_action]
          render :json => { :power => @host.power.send(params[:power_action]) }, :status => :ok
        else
          render :json => { :error => _("Unknown power action: available methods are %s") % valid_actions.join(', ') }, :status => :unprocessable_entity
        end
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
      end

      api :POST, "/hosts/facts", N_("Upload facts for a host, creating the host if required")
      param :name, String, :required => true, :desc => N_("hostname of the host")
      param :facts, Hash,      :required => true, :desc => N_("hash containing the facts for the host")
      param :certname, String, :desc => N_("optional: certname of the host")
      param :type, String,     :desc => N_("optional: the STI type of host to create")

      def facts
        @host = detect_host_type.import_host params[:name], params[:facts][:_type] || 'puppet', params[:certname], detected_proxy.try(:id)
        state = @host.import_facts(params[:facts])
        process_response state
      rescue ::Foreman::Exception => e
        render_message(e.to_s, :status => :unprocessable_entity)
      end

      api :PUT, "/hosts/:id/rebuild_config", N_("Rebuild orchestration config")
      param :id, :identifier_dottable, :required => true
      def rebuild_config
        result = @host.recreate_config
        failures = result.reject { |key, value| value }.keys.map{ |k| _(k) }
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
          render :json => { :template => @host.render_template(template) }, :status => :ok
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
          if params[:interfaces_attributes].is_a? Hash
            params[:interfaces_attributes] = params[:interfaces_attributes].values
          end
          # map interface types
          params[:interfaces_attributes] = params[:interfaces_attributes].map do |nic_attr|
            interface_attributes(nic_attr)
          end
        end
        params = host.apply_inherited_attributes(params) if host
        params
      end

      def interface_attributes(params)
        params[:type] = InterfaceTypeMapper.map(params[:type])
        params
      end

      def action_permission
        case params[:action]
          when 'puppetrun'
            :puppetrun
          when 'power'
            :power
          when 'boot'
            :ipmi_boot
          when 'console'
            :console
          when 'disassociate'
            :edit
          when 'vm_compute_attributes', 'get_status', 'template', 'enc'
            :view
          when 'rebuild_config'
            :build
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
          return params[:type].constantize
        else
          raise ::Foreman::Exception.new(N_("Invalid type for host creation via facts: %s"), params[:type])
        end
      rescue => e
        raise ::Foreman::Exception.new(N_("A problem occurred when detecting host type: %s"), e.message)
      end

      def permissions_check
        permission = "#{params[:action]}_hosts".to_sym
        deny_access unless Host.authorized(permission, Host).find(@host.id)
      end

      def resource_class
        Host::Managed
      end

      def allowed_nested_id
        %w(hostgroup_id location_id organization_id environment_id)
      end
    end
  end
end
