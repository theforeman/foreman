module FogExtensions
  module Vsphere
    module Server
      extend ActiveSupport::Concern

      attr_accessor :image_id
      attr_accessor :add_cdrom

      def to_s
        name
      end

      def state
        power_state
      end

      def interfaces_attributes=(attrs); end

      def volumes_attributes=(attrs); end

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
        nic_attrs = nic.compute_attributes
        selected_nic = fog_nics.detect { |fn| fn.network == nic_attrs['network'] } # grab any nic on the same network
        unless selected_nic
          vm_network = service.get_network(nic_attrs['network'], datacenter)
          if vm_network && vm_network.key?(:id)
            selected_nic = fog_nics.detect { |fn| fn.network == vm_network[:id] } # try and match on portgroup
          end
        end
        selected_nic
      end
    end
  end
end
