module FogExtensions
  module Vsphere
    module Server
      extend ActiveSupport::Concern

      attr_accessor :image_id

      def to_s
        name
      end

      def state
        power_state
      end

      def interfaces_attributes=(attrs); end

      def volumes_attributes=(attrs);  end

      def poweroff
        stop(:force => true)
      end

      def reset
        reboot(:force => true)
      end

      def vm_description
        _("%{cpus} CPUs and %{memory} MB memory") % {:cpus => cpus, :memory => memory_mb.to_i}
      end

      def scsi_controller_type
        return scsi_controller[:type] if scsi_controller.is_a?(Hash)
        scsi_controller.type
      end

      def select_nic(fog_nics, nic)
        fog_nics.detect {|fn| fn.network == nic.compute_attributes['network']} # grab any nic on the same network
      end

    end
  end
end
