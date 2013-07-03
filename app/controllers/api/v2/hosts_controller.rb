module Api
  module V2
    class HostsController < V1::HostsController
      include Api::Version2

      before_filter :find_resource

      api :GET, "/hosts/:id/puppetrun", "Force a puppet run on the agent."

      def puppetrun
        return deny_access unless Setting[:puppetrun]
        process_response @host.puppetrun!
      end

      api :PUT, "/hosts/:id/power", "Run power operation on interface. "
      param :id, String, :required => true, :desc => "id of interface"
      param :power_action, String, :required => true, :desc => "power action, valid actions are ('on', 'start')', ('off', 'stop'), ('soft', 'reboot'), ('cycle', 'reset'), ('state', 'status')"

      def power
        valid_actions = PowerManager::SUPPORTED_ACTIONS
        if valid_actions.include? params[:power_action]
          render :json => { :power => @host.power.send(params[:power_action]) } , :status => 200
        else
          render :json => { :error => "Unknown power action: Available methods are #{valid_actions.join(', ')}" }, :status => 422
        end
      end

      api :PUT, "/hosts/:id/boot", "Interface boots from specified device."
      param :id, String, :required => true, :desc => "id of interface"
      param :device, String, :required => true, :desc => "boot device, valid devices are disk, cdrom, pxe, bios"

      def boot
        valid_devices = ProxyAPI::BMC::SUPPORTED_BOOT_DEVICES
        if valid_devices.include? params[:device]
          render :json => { :boot => @host.ipmi_boot(params[:device]) }, :status => 200
        else
          render :json => { :error => "Unknown device: Available devices are #{valid_devices.join(', ')}" }, :status => 422
        end
      end

    end
  end
end
