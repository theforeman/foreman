module FogExtensions
  module Vsphere
    class MiniServer
      attr_reader :name, :identity, :cpus, :memory, :state, :path

      def initialize (raw, path = nil, uuid = nil)
        hardware  = raw.config.hardware
        @raw      = raw
        @name     = raw.name
        @identity = uuid
        @cpus     = hardware.numCPU
        @memory   = hardware.memoryMB * 1024 * 1024
        @state    = raw.runtime.powerState
        @path     = path
      end

      def ready?
        @state == "poweredOn"
      end

      private
      attr_reader :raw
    end
  end
end
