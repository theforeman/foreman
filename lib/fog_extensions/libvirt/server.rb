module FogExtensions
  module Libvirt
    module Server

      def nics_attributes=(attrs); end

      def volumes_attributes=(attrs); end

      # Libvirt expect units in KB, while we use bytes
      def memory
        attributes[:memory_size].to_i * 1024
      end

      def memory= mem
        attributes[:memory_size] = mem.to_i / 1024 if mem
      end

    end
  end
end