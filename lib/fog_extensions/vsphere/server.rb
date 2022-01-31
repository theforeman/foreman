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

      def interfaces_attributes=(attrs)
      end

      def volumes_attributes=(attrs)
      end

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
        all_networks = service.list_networks(datacenter: datacenter)
        vm_network = all_networks.detect { |network| nic_attrs['network'] && [network[:name], network[:id]].compact.include?(nic_attrs['network']) }
        vm_network ||= all_networks.detect { |network| network[:_ref] == nic_attrs['network'] }
        unless vm_network
          Rails.logger.info "Could not find Vsphere network for #{nic_attrs.inspect}"
          return
        end
        selected_nic = fog_nics.detect { |fn| fn.network == vm_network[:name] } # grab any nic on the same network
        if selected_nic.nil? && vm_network[:id].present?
          selected_nic = fog_nics.detect { |fn| fn.network == vm_network[:id] } # try to match on portgroup
        end
        selected_nic
      end
    end
  end
end
