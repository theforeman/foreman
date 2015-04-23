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
        nic_attrs = nic.compute_attributes
        selected_nic =   fog_nics.detect { |fn| fn.network == nic_attrs['network'] } # grab any nic on the same network
        selected_nic ||= if service.get_network(nic_attrs['network'], datacenter).key?(:id)
                           fog_nics.detect { |fn| fn.network  == service.get_network(nic_attrs['network'], datacenter)[:id]  } # no network? try the portgroup
                         else
                           nil
                         end
        selected_nic
      end
    end
  end
end
