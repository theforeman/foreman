module FogExtensions
  module Vsphere
    module Server
      extend ActiveSupport::Concern

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

    end
  end
end
