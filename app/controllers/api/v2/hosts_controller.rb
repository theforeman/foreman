module Api
  module V2
    class HostsController < V1::HostsController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      before_filter :find_resource, :except => :facts
      add_puppetmaster_filters :facts

      api :GET, "/hosts/:id/puppetrun", "Force a puppet run on the agent."

      def puppetrun
        return deny_access unless Setting[:puppetrun]
        process_response @host.puppetrun!
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
        @host, state = detect_host_type.importHostAndFacts params[:name],params[:facts],params[:certname]
        process_response state
      rescue ::Foreman::Exception => e
        render :json => {'message'=>e.to_s}, :status => :unprocessable_entity
      end

      private

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

    end
  end
end
