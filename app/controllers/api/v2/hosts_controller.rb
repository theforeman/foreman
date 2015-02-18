module Api
  module V2
    class HostsController < V2::BaseController
      wrap_parameters :host, :include => (Host::Base.attribute_names + ['image_file', 'is_owned_by', 'overwrite', 'progress_report_id'])

      include Api::Version2
      include Api::TaxonomyScope
      include Foreman::Controller::SmartProxyAuth

      before_filter :find_optional_nested_object, :except => [:facts]
      before_filter :find_resource, :except => [:index, :create, :facts]
      before_filter :permissions_check, :only => %w{power boot puppetrun}

      add_smart_proxy_filters :facts, :features => FactImporter.fact_features

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
        @hosts = resource_scope_for_index
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
          param :puppet_class_ids, Array
          param :operatingsystem_id, String, :desc => N_("required if host is managed and value is not inherited from host group")
          param :medium_id, String, :desc => N_("required if not imaged based provisioning and host is managed and value is not inherited from host group")
          param :ptable_id, :number, :desc => N_("required if host is managed and custom partition has not been defined")
          param :subnet_id, :number, :desc => N_("required if host is managed and value is not inherited from host group")
          param :compute_resource_id, :number, :desc => N_("nil means host is bare metal")
          param :root_pass, String, :desc => N_("required if host is managed and value is not inherited from host group or default password in settings")
          param :model_id, :number
          param :hostgroup_id, :number
          param :owner_id, :number
          param :puppet_ca_proxy_id, :number
          param :image_id, :number
          param :host_parameters_attributes, Array
          param :build, :bool
          param :enabled, :bool
          param :provision_method, String
          param :managed, :bool, :desc => N_("True/False flag whether a host is managed or unmanaged. Note: this value also determines whether several parameters are required or not")
          param :progress_report_id, String, :desc => N_("UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks")
          param :comment, String, :desc => N_("Additional information about this host")
          param :capabilities, String
          param :compute_profile_id, :number
          param :compute_attributes, Hash do
          end
        end
      end

      api :POST, "/hosts/", N_("Create a host")
      param_group :host, :as => :create

      def create
        @host = Host.new(params[:host])
        @host.managed = true if (params[:host] && params[:host][:managed].nil?)
        forward_request_url
        process_response @host.save
      end

      api :PUT, "/hosts/:id/", N_("Update a host")
      param :id, :identifier, :required => true
      param_group :host

      def update
        process_response @host.update_attributes(params[:host])
      end

      api :DELETE, "/hosts/:id/", N_("Delete a host")
      param :id, :identifier, :required => true

      def destroy
        process_response @host.destroy
      end

      api :GET, "/hosts/:id/status", N_("Get status of host")
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
        render :json => { :status => @host.host_status }.to_json if @host
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
        @host, state = detect_host_type.import_host_and_facts params[:name], params[:facts], params[:certname], detected_proxy.try(:id)
        process_response state
      rescue ::Foreman::Exception => e
        render :json => {'message'=>e.to_s}, :status => :unprocessable_entity
      end

      private

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
        if params[:type].constantize.new.kind_of?(Host::Base)
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
        deny_access unless Host.authorized(permission).find(@host.id)
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

