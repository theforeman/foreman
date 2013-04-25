require 'fog_extensions/vsphere/mini_server'

module FogExtensions
  module Vsphere
    class MiniServers

      def initialize client, dc
        @client = client
        @dc     = client.send(:find_datacenters, dc)[0]
      end

      def all(filters = { })
        dc.vmFolder.childEntity.grep(RbVmomi::VIM::VirtualMachine).map do |server|
          MiniServer.new(server)
        end
      end

      private
      attr_reader :client, :dc
    end
  end
end