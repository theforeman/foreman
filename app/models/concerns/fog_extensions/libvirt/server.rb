module FogExtensions
  module Libvirt
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      attr_accessor :image_id

      def to_s
        name
      end

      def cpu_mode
        attributes[:cpu][:mode]
      end

      def cpu_mode=(cpumode)
        attributes[:cpu][:mode] = (cpumode == 'default') ? nil : cpumode
      end

      def nics_attributes=(attrs)
      end

      def volumes_attributes=(attrs)
      end

      # Libvirt expect units in KB, while we use bytes
      def memory
        attributes[:memory_size].to_i.kilobytes
      end

      def memory=(mem)
        attributes[:memory_size] = mem.to_i / 1.kilobyte if mem
      end

      def reset
        poweroff
        start
      end

      def vm_description
        _("%{cpus} CPUs and %{memory} memory") % {:cpus => cpus, :memory => number_to_human_size(memory.to_i)}
      end

      # Other Fog CRs use .interfaces as the accessor, but libvirt does not
      def interfaces
        nics
      end

      def select_nic(fog_nics, nic)
        nic_attrs = nic.compute_attributes
        match =   fog_nics.detect { |fn| fn.network == nic_attrs['network'] } # grab any nic on the same network
        match ||= fog_nics.detect { |fn| fn.bridge  == nic_attrs['bridge']  } # no network? try a bridge...
        match
      end
    end
  end
end
