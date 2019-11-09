module FogExtensions
  module Vsphere
    class MiniServer
      attr_reader :name, :identity, :cpus, :corespersocket, :memory, :state, :path, :operatingsystem, :hypervisor

      def initialize(attrs = {})
        @name     = attrs[:name]
        @identity = attrs[:identity]
        @cpus     = attrs[:cpus]
        @corespersocket = attrs[:corespersocket]
        @memory = attrs[:memory].megabytes
        @state = attrs[:state]
        @path = attrs[:path]
        @operatingsystem = attrs[:operatingsystem]
        @hypervisor = attrs[:hypervisor]
      end

      def ready?
        @state == "poweredOn"
      end

      def to_s
        name
      end

      alias_method :id, :identity
    end
  end
end
