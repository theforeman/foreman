module FogExtensions
  module Libvirt
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      attr_accessor :image_id

      def to_s
        name
      end

      def nics_attributes=(attrs); end

      def volumes_attributes=(attrs); end

      # Libvirt expect units in KB, while we use bytes
      def memory
        attributes[:memory_size].to_i * 1024
      end

      def memory=(mem)
        attributes[:memory_size] = mem.to_i / 1024 if mem
      end

      def reset
        # @TODO: change to poweroff && start upon fix for LibVirt on Fog gem.
        service.vm_action(uuid, :reset)
      end

      def vm_description
        _("%{cpus} CPUs and %{memory} memory") % {:cpus => cpus, :memory => number_to_human_size(memory.to_i)}
      end

    end
  end
end
