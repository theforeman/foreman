module Api
  module V2
    class HostsController < V2::BaseController

      include Api::Version2
      #TODO - should TaxonomyScope be here.  It wasn't here previously
      include Api::TaxonomyScope
      include Foreman::Controller::SmartProxyAuth

      before_filter :find_resource, :except => %w{index create facts}
      before_filter :permissions_check, :only => %w{power boot puppetrun}
      add_puppetmaster_filters :facts

      api :GET, "/hosts/", "List all hosts."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @hosts = resource_scope.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/hosts/:id/", "Show a host."
      param :id, :identifier_dottable, :required => true

      def show
      end

      def_param_group :host do
        param :host, Hash, :action_aware => true do
          param :name, String, :required => true
          param :environment_id, String
          param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
          param :mac, String, :desc => "not required if its a virtual machine"
          param :architecture_id, :number
          param :domain_id, :number
          param :realm_id, :number
          param :puppet_proxy_id, :number
          param :puppet_class_ids, Array
          param :operatingsystem_id, String
          param :medium_id, :number
          param :ptable_id, :number
          param :subnet_id, :number
          param :compute_resource_id, :number
          param :sp_subnet_id, :number
          param :model_id, :number
          param :hostgroup_id, :number
          param :owner_id, :number
          param :puppet_ca_proxy_id, :number
          param :image_id, :number
          param :host_parameters_attributes, Array
          param :build, :bool
          param :enabled, :bool
          param :provision_method, String
          param :managed, :bool
          param :progress_report_id, String, :desc => 'UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks'
          param :capabilities, String
          param :compute_profile_id, :number
          param :compute_attributes, Hash do
          end
        end
      end


      api :POST, "/hosts/", "Create a host."
      param_group :host, :as => :create

      def create
        @host = Host.new(params[:host])
        @host.managed = true if (params[:host] && params[:host][:managed].nil?)
        forward_request_url
        process_response @host.save
      end

      api :PUT, "/hosts/:id/", "Update a host."
      param :id, :identifier, :required => true
      param_group :host

      def update
        process_response @host.update_attributes(params[:host])
      end

      api :DELETE, "/hosts/:id/", "Delete an host."
      param :id, :identifier, :required => true

      def destroy
        process_response @host.destroy
      end

      api :GET, "/hosts/:id/status", "Get status of host"
      param :id, :identifier_dottable, :required => true
      # TRANSLATORS: API documentation - do not translate
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

      api :PUT, "/hosts/:id/puppetrun", "Force a puppet run on the agent."
      param :id, :identifier_dottable, :required => true

      def puppetrun
        return deny_access unless Setting[:puppetrun]
        process_response @host.puppetrun!
      end

      api :PUT, "/hosts/:id/disassociate", "Disassociate the host from a VM."
      param :id, :identifier_dottable, :required => true
      def disassociate
        @host.disassociate!
        render 'api/v2/hosts/show'
      end

      api :PUT, "/hosts/:id/power", "Run power operation on host."
      param :id, :identifier_dottable, :required => true
      param :power_action, String, :required => true, :desc => "power action, valid actions are ('on', 'start')', ('off', 'stop'), ('soft', 'reboot'), ('cycle', 'reset'), ('state', 'status')"

      def power
        valid_actions = PowerManager::SUPPORTED_ACTIONS
        if valid_actions.include? params[:power_action]
          render :json => { :power => @host.power.send(params[:power_action]) } , :status => 200
        else
          render :json => { :error => "Unknown power action: Available methods are #{valid_actions.join(', ')}" }, :status => 422
        end
      end

      api :PUT, "/hosts/:id/boot", "Boot host from specified device."
      param :id, :identifier_dottable, :required => true
      param :device, String, :required => true, :desc => "boot device, valid devices are disk, cdrom, pxe, bios"

      def boot
        valid_devices = ProxyAPI::BMC::SUPPORTED_BOOT_DEVICES
        if valid_devices.include? params[:device]
          render :json => { :boot => @host.ipmi_boot(params[:device]) }, :status => 200
        else
          render :json => { :error => "Unknown device: Available devices are #{valid_devices.join(', ')}" }, :status => 422
        end
      end

      api :POST, "/hosts/facts", "Upload facts for a host, creating the host if required."
      param :name, String, :required => true, :desc => "hostname of the host"
      param :facts, Hash,      :required => true, :desc => "hash containing the facts for the host"
      param :certname, String, :desc => "optional: certname of the host"
      param :type, String,     :desc => "optional: the STI type of host to create"

      def facts
        @host, state = detect_host_type.import_host_and_facts params[:name], params[:facts], params[:certname], detected_proxy.try(:id)
        process_response state
      rescue ::Foreman::Exception => e
        render :json => {'message'=>e.to_s}, :status => :unprocessable_entity
      end

      private

      def resource_scope(controller = controller_name)
        Host.authorized("#{action_permission}_#{controller}", Host)
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
          raise "Invalid type for host creation via facts: #{params[:type]}"
        end
      rescue => e
        raise ::Foreman::Exception.new("A problem occurred when detecting host type: #{e.message}")
      end

      def permissions_check
        permission = "#{params[:action]}_hosts".to_sym
        deny_access unless Host.authorized(permission).find(@host.id)
      end

    end
  end
end

