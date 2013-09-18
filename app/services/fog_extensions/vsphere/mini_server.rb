module FogExtensions
  module Vsphere
    class MiniServer
      attr_reader :name, :identity, :cpus, :memory, :ready
      alias_method :ready?, :ready

      def initialize (raw, path = nil)
        @raw      = raw
        @name     = raw.name
        @identity = raw.config.instanceUuid
        @cpus     = raw.config.hardware.numCPU
        @memory   = raw.config.hardware.memoryMB * 1024 * 1024
        @ready    = raw.runtime.powerState == "poweredOn"
        @path     = path
      end

      def state
        raw.runtime.powerState
      end

      def path
        @path
      end

      private
      attr_reader :raw
    end
  end
end
